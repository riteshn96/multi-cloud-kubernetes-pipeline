from flask import Flask
import os

# Create an instance of the Flask class
app = Flask(__name__)

# Define a route for the default URL ("/")
@app.route('/')
def hello():
    # Get an environment variable named 'CLOUD_PROVIDER'. 
    # If it's not set, it defaults to 'Unknown'.
    provider = os.environ.get('CLOUD_PROVIDER', 'Unknown') 
    
    # Return a string that will be displayed in the browser
    return f'Hello, World! I am running on {provider}!'

# This part runs the app when the script is executed directly
if __name__ == '__main__':
    # Run the web server on all available network interfaces (0.0.0.0)
    # and listen on port 80.
    app.run(host='0.0.0.0', port=80)