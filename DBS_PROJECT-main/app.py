from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# Database connection function
def get_db_connection():
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="dbs123",
        database="inv_man"
    )
    return conn

# Create database if it doesn't exist
def init_db():
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="dbs123"
    )
    cursor = conn.cursor()
    cursor.execute("CREATE DATABASE IF NOT EXISTS inv_man")
    conn.commit()
    cursor.close()
    conn.close()

# Login required decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login to access this page', 'danger')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# Admin required decorator
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session or 'is_admin' not in session or not session['is_admin']:
            flash('Admin access required', 'danger')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated_function

# Routes
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Product LIMIT 10")
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', products=products)

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        password = request.form['password']
        address = request.form['address']
        phone = request.form['phone']
        
        hashed_password = generate_password_hash(password)
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute(
                "INSERT INTO Users (Password, Cname, Address, Phone, Email) VALUES (%s, %s, %s, %s, %s)",
                (hashed_password, name, address, phone, email)
            )
            conn.commit()
            flash('Registration successful! Please login.', 'success')
            return redirect(url_for('login'))
        except mysql.connector.Error as err:
            flash(f'Registration failed: {err}', 'danger')
        finally:
            cursor.close()
            conn.close()
            
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute("SELECT * FROM Users WHERE Email = %s", (email,))
        user = cursor.fetchone()
        
        # Option A: Handle both hashed passwords and plaintext passwords
        if user and (check_password_hash(user['Password'], password) or user['Password'] == password):
            session['user_id'] = user['userID']
            session['user_name'] = user['Cname']
            session['is_admin'] = True if user['AdminID'] else False
            
            flash('Login successful!', 'success')
            
            # Redirect based on role
            if session['is_admin']:
                return redirect(url_for('admin_dashboard'))
            else:
                return redirect(url_for('index'))
        else:
            flash('Invalid email or password', 'danger')
        
        cursor.close()
        conn.close()
        
    return render_template('login.html')




@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out', 'info')
    return redirect(url_for('index'))

@app.route('/product/<int:product_id>')
def product_detail(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT p.*, s.Quantity 
        FROM Product p
        JOIN Storage s ON p.StorageID = s.StorageID
        WHERE p.PID = %s
    """, (product_id,))
    product = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    if not product:
        flash('Product not found', 'danger')
        return redirect(url_for('index'))
        
    return render_template('product_detail.html', product=product)

@app.route('/add_to_cart', methods=['POST'])
@login_required
def add_to_cart():
    product_id = request.form.get('product_id')
    quantity = int(request.form.get('quantity', 1))
    
    if 'cart' not in session:
        session['cart'] = {}
    
    cart = session['cart']
    
    if product_id in cart:
        cart[product_id] += quantity
    else:
        cart[product_id] = quantity
    
    session['cart'] = cart
    flash('Product added to cart', 'success')
    
    return redirect(request.referrer or url_for('index'))

@app.route('/cart')
@login_required
def view_cart():
    if 'cart' not in session or not session['cart']:
        return render_template('cart.html', cart_items=[], total=0)
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cart_items = []
    total = 0
    
    for product_id, quantity in session['cart'].items():
        cursor.execute("SELECT * FROM Product WHERE PID = %s", (product_id,))
        product = cursor.fetchone()
        
        if product:
            item_total = float(product['Price']) * quantity
            cart_items.append({
                'product': product,
                'quantity': quantity,
                'subtotal': item_total
            })
            total += item_total
    
    cursor.close()
    conn.close()
    
    return render_template('cart.html', cart_items=cart_items, total=total)

@app.route('/update_cart', methods=['POST'])
@login_required
def update_cart():
    product_id = request.form.get('product_id')
    quantity = int(request.form.get('quantity', 0))
    
    if 'cart' in session and product_id in session['cart']:
        if quantity > 0:
            session['cart'][product_id] = quantity
        else:
            del session['cart'][product_id]
        
        session.modified = True
    
    return redirect(url_for('view_cart'))

@app.route('/checkout', methods=['GET', 'POST'])
@login_required
def checkout():
    if 'cart' not in session or not session['cart']:
        flash('Your cart is empty', 'warning')
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        address = request.form.get('address')
        pincode = request.form.get('pincode')
        city = request.form.get('city')
        country = request.form.get('country')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            # Create delivery record
            cursor.execute(
                "INSERT INTO Delivery (Address, PinCode) VALUES (%s, %s)",
                (address, pincode)
            )
            delivery_id = cursor.lastrowid
            
            # Create location record
            cursor.execute(
                "INSERT INTO Location (DeliveryID, City, Street, Country, Cname) VALUES (%s, %s, %s, %s, %s)",
                (delivery_id, city, address.split(',')[0], country, session['user_name'])
            )
            
            # Calculate total amount
            total = 0
            for product_id, quantity in session['cart'].items():
                cursor.execute("SELECT Price FROM Product WHERE PID = %s", (product_id,))
                price = cursor.fetchone()[0]
                total += float(price) * quantity
            
            # Create order
            cursor.execute(
                "INSERT INTO Orders (Date, Amount, userID, EmployeeID, InventoryID) VALUES (%s, %s, %s, %s, %s)",
                (datetime.now().strftime('%Y-%m-%d'), total, session['user_id'], 1, 1)  # Assuming employee and inventory IDs
            )
            order_id = cursor.lastrowid
            
            # Link order to delivery
            cursor.execute(
                "INSERT INTO Order_Delivery (OrderNo, DeliveryID) VALUES (%s, %s)",
                (order_id, delivery_id)
            )
            
            # Add products to order
            for product_id, quantity in session['cart'].items():
                cursor.execute("SELECT Price FROM Product WHERE PID = %s", (product_id,))
                price = cursor.fetchone()[0]
                
                cursor.execute(
                    "UPDATE Product SET OrderNo = %s WHERE PID = %s",
                    (order_id, product_id)
                )
                
                # Update inventory
                cursor.execute(
                    """
                    UPDATE Storage 
                    SET Quantity = Quantity - %s 
                    WHERE StorageID = (SELECT StorageID FROM Product WHERE PID = %s)
                    """,
                    (quantity, product_id)
                )
            
            # Create invoice
            cursor.execute(
                "INSERT INTO Invoice (OrderNo, UserID) VALUES (%s, %s)",
                (order_id, session['user_id'])
            )
            
            conn.commit()
            
            # Clear cart
            session.pop('cart', None)
            
            flash('Order placed successfully!', 'success')
            return redirect(url_for('order_confirmation', order_id=order_id))
            
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error placing order: {err}', 'danger')
        finally:
            cursor.close()
            conn.close()
    
    # Get cart items for display
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cart_items = []
    total = 0
    
    for product_id, quantity in session['cart'].items():
        cursor.execute("SELECT * FROM Product WHERE PID = %s", (product_id,))
        product = cursor.fetchone()
        
        if product:
            item_total = float(product['Price']) * quantity
            cart_items.append({
                'product': product,
                'quantity': quantity,
                'subtotal': item_total
            })
            total += item_total
    
    # Get user info
    cursor.execute("SELECT * FROM Users WHERE userID = %s", (session['user_id'],))
    user = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    return render_template('checkout.html', cart_items=cart_items, total=total, user=user)

@app.route('/order_confirmation/<int:order_id>')
@login_required
def order_confirmation(order_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.*, d.Address, d.PinCode, l.City, l.Country
        FROM Orders o
        JOIN Order_Delivery od ON o.OrderNo = od.OrderNo
        JOIN Delivery d ON od.DeliveryID = d.DeliveryID
        JOIN Location l ON d.DeliveryID = l.DeliveryID
        WHERE o.OrderNo = %s AND o.userID = %s
    """, (order_id, session['user_id']))
    
    order = cursor.fetchone()
    
    if not order:
        flash('Order not found', 'danger')
        return redirect(url_for('index'))
    
    cursor.execute("SELECT p.* FROM Product p WHERE p.OrderNo = %s", (order_id,))
    order_items = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('order_confirmation.html', order=order, items=order_items)

@app.route('/orders')
@login_required
def order_history():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.*, i.InvoiceID
        FROM Orders o
        LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
        WHERE o.userID = %s
        ORDER BY o.Date DESC
    """, (session['user_id'],))
    
    orders = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('orders.html', orders=orders)

@app.route('/order/<int:order_id>')
@login_required
def order_detail(order_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.*, d.Address, d.PinCode, l.City, l.Country, i.InvoiceID
        FROM Orders o
        JOIN Order_Delivery od ON o.OrderNo = od.OrderNo
        JOIN Delivery d ON od.DeliveryID = d.DeliveryID
        JOIN Location l ON d.DeliveryID = l.DeliveryID
        LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
        WHERE o.OrderNo = %s AND o.userID = %s
    """, (order_id, session['user_id']))
    
    order = cursor.fetchone()
    
    if not order:
        flash('Order not found', 'danger')
        return redirect(url_for('orders'))
    
    cursor.execute("SELECT p.* FROM Product p WHERE p.OrderNo = %s", (order_id,))
    order_items = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('order_detail.html', order=order, items=order_items)

@app.route('/profile')
@login_required
def profile():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM Users WHERE userID = %s", (session['user_id'],))
    user = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    return render_template('profile.html', user=user)

@app.route('/edit_profile', methods=['GET', 'POST'])
@login_required
def edit_profile():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if request.method == 'POST':
        name = request.form['name']
        address = request.form['address']
        phone = request.form['phone']
        email = request.form['email']
        
        try:
            cursor.execute(
                "UPDATE Users SET Cname = %s, Address = %s, Phone = %s, Email = %s WHERE userID = %s",
                (name, address, phone, email, session['user_id'])
            )
            conn.commit()
            session['user_name'] = name
            flash('Profile updated successfully', 'success')
            return redirect(url_for('profile'))
        except mysql.connector.Error as err:
            flash(f'Error updating profile: {err}', 'danger')
    
    cursor.execute("SELECT * FROM Users WHERE userID = %s", (session['user_id'],))
    user = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    return render_template('edit_profile.html', user=user)

# Admin routes
@app.route('/admin')
@admin_required
def admin_dashboard():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT COUNT(*) as order_count FROM Orders")
    order_count = cursor.fetchone()['order_count']
    
    cursor.execute("SELECT COUNT(*) as user_count FROM Users")
    user_count = cursor.fetchone()['user_count']
    
    cursor.execute("SELECT COUNT(*) as product_count FROM Product")
    product_count = cursor.fetchone()['product_count']
    
    cursor.execute("""
        SELECT o.*, u.Cname
        FROM Orders o
        JOIN Users u ON o.userID = u.userID
        ORDER BY o.Date DESC
        LIMIT 10
    """)
    recent_orders = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/dashboard.html', 
                          order_count=order_count,
                          user_count=user_count,
                          product_count=product_count,
                          recent_orders=recent_orders)

@app.route('/admin/orders')
@admin_required
def admin_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.*, u.Cname, i.InvoiceID
        FROM Orders o
        JOIN Users u ON o.userID = u.userID
        LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
        ORDER BY o.Date DESC
    """)
    
    orders = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/orders.html', orders=orders)

@app.route('/admin/products')
@admin_required
def admin_products():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT p.*, s.Quantity, sup.Sname
        FROM Product p
        JOIN Storage s ON p.StorageID = s.StorageID
        JOIN Supplier sup ON p.SupID = sup.SupID
        ORDER BY p.PID  -- Add this line to sort by PID
    """)
    
    products = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/products.html', products=products)


@app.route('/admin/users')
@admin_required
def admin_users():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM Users")
    users = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/users.html', users=users)

@app.route('/admin/order/<int:order_id>')
@admin_required
def admin_order_detail(order_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT o.*, d.Address, d.PinCode, l.City, l.Country, i.InvoiceID, u.Cname as CustomerName
        FROM Orders o
        JOIN Order_Delivery od ON o.OrderNo = od.OrderNo
        JOIN Delivery d ON od.DeliveryID = d.DeliveryID
        JOIN Location l ON d.DeliveryID = l.DeliveryID
        LEFT JOIN Invoice i ON o.OrderNo = i.OrderNo
        JOIN Users u ON o.userID = u.userID
        WHERE o.OrderNo = %s
    """, (order_id,))
    
    order = cursor.fetchone()
    
    if not order:
        flash('Order not found', 'danger')
        return redirect(url_for('admin_orders'))
    
    cursor.execute("SELECT p.* FROM Product p WHERE p.OrderNo = %s", (order_id,))
    order_items = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/order_detail.html', order=order, items=order_items)

@app.route('/admin/products/add', methods=['GET', 'POST'])
@admin_required
def admin_add_product():
    if request.method == 'POST':
        # Get form data
        name = request.form.get('name')
        category = request.form.get('category')
        price = request.form.get('price')
        supplier_id = request.form.get('supplier_id')
        storage_id = request.form.get('storage_id')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            # Get the maximum PID value
            cursor.execute("SELECT MAX(PID) FROM Product")
            max_pid = cursor.fetchone()[0]
            new_pid = 1 if max_pid is None else max_pid + 1
            
            # Insert product with explicit PID
            cursor.execute(
                "INSERT INTO Product (PID, Pname, Category, Price, SupID, StorageID) VALUES (%s, %s, %s, %s, %s, %s)",
                (new_pid, name, category, price, supplier_id, storage_id)
            )
            
            conn.commit()
            flash('Product added successfully!', 'success')
            return redirect(url_for('admin_products'))
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error adding product: {err}', 'danger')
        finally:
            cursor.close()
            conn.close()
    
    # Get suppliers and storage options for the form
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM Supplier")
    suppliers = cursor.fetchall()
    
    cursor.execute("SELECT * FROM Storage")
    storage_options = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/add_product.html', suppliers=suppliers, storage_options=storage_options)

@app.route('/admin/products/edit/<int:product_id>', methods=['GET', 'POST'])
@admin_required
def admin_edit_product(product_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if request.method == 'POST':
        # Get form data
        name = request.form.get('name')
        category = request.form.get('category')
        price = request.form.get('price')
        supplier_id = request.form.get('supplier_id')
        storage_id = request.form.get('storage_id')
        quantity = request.form.get('quantity')
        
        try:
            # Update product
            cursor.execute(
                "UPDATE Product SET Pname = %s, Category = %s, Price = %s, SupID = %s, StorageID = %s WHERE PID = %s",
                (name, category, price, supplier_id, storage_id, product_id)
            )
            
            # Update storage quantity
            cursor.execute(
                "UPDATE Storage SET Quantity = %s WHERE StorageID = %s",
                (quantity, storage_id)
            )
            
            conn.commit()
            flash('Product updated successfully!', 'success')
            return redirect(url_for('admin_products'))
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error updating product: {err}', 'danger')
    
    # Get product data
    cursor.execute("""
        SELECT p.*, s.Quantity 
        FROM Product p
        JOIN Storage s ON p.StorageID = s.StorageID
        WHERE p.PID = %s
    """, (product_id,))
    product = cursor.fetchone()
    
    if not product:
        flash('Product not found', 'danger')
        return redirect(url_for('admin_products'))
    
    # Get suppliers and storage options for the form
    cursor.execute("SELECT * FROM Supplier")
    suppliers = cursor.fetchall()
    
    cursor.execute("SELECT * FROM Storage")
    storage_options = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('admin/edit_product.html', product=product, suppliers=suppliers, storage_options=storage_options)

@app.route('/admin/products/delete/<int:product_id>', methods=['POST'])
@admin_required
def admin_delete_product(product_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Check if product is part of any order
        cursor.execute("SELECT COUNT(*) FROM Product WHERE PID = %s AND OrderNo IS NOT NULL", (product_id,))
        is_ordered = cursor.fetchone()[0] > 0
        
        if is_ordered:
            flash('Cannot delete product that is part of an order', 'danger')
            return redirect(url_for('admin_products'))
        
        # Delete product
        cursor.execute("DELETE FROM Product WHERE PID = %s", (product_id,))
        conn.commit()
        flash('Product deleted successfully!', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error deleting product: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('admin_products'))

@app.route('/search')
def search():
    search_query = request.args.get('search', '')
    
    if not search_query:
        return redirect(url_for('index'))
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT p.*, s.Quantity 
        FROM Product p
        JOIN Storage s ON p.StorageID = s.StorageID
        WHERE p.Pname LIKE %s OR p.Category LIKE %s
    """, (f'%{search_query}%', f'%{search_query}%'))
    
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    
    return render_template('index.html', products=products, search_query=search_query)



# Initialize database
init_db()

if __name__ == '__main__':
    app.run(debug=True)
