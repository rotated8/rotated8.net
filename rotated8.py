from flask import Flask
from werkzeug.contrib.fixers import ProxyFix
app = Flask('site')

@app.route('/')
def hello():
    return 'Hello world!'

app.wsgi_app = ProxyFix(app.wsgi_app)

if __name__ == '__main__':
    app.run()
