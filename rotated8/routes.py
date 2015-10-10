from rotated8 import app
from flask import render_template
import mgsv_names
@app.route('/')
def hello():
    return 'Hello world!'

@app.route('/names')
def names():
    name = mgsv_names.generate_name()
    return render_template('names.html', name=name)
