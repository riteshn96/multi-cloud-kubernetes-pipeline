# --- Stage 1: The Builder ---
# We start with a full Python image to install our dependencies
FROM python:3.9-slim AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file first to leverage Docker's layer caching
COPY requirements.txt .

# Install the Python packages
RUN pip install --no-cache-dir -r requirements.txt


# --- Stage 2: The Final Production Image ---
# We start from a "slim" Python image, which is much smaller
FROM python:3.9-slim-bookworm

# Set the working directory again
WORKDIR /app

# Copy the installed packages from the "builder" stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy our application code
COPY app.py .

# Expose the port the app runs on
EXPOSE 80

# The command to run when the container starts
CMD ["python", "app.py"]