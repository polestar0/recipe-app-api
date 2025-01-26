FROM python:3.9-alpine3.13

LABEL maintainer="dhruv"

ENV PYTHONUNBUFFERED 1

# Step 1: Copy files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

EXPOSE 8000

ARG DEV=false

# Step 2: Create a virtual environment
RUN echo "Creating virtual environment..." && \
    python -m venv /py

# Step 3: Upgrade pip
RUN echo "Upgrading pip..." && \
    /py/bin/pip install --upgrade pip

# Step 4: Install PostgreSQL client
RUN echo "Installing PostgreSQL client..." && \
    apk add --update --no-cache postgresql-client

# Step 5: Install build dependencies
RUN echo "Installing build dependencies..." && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev

# Step 6: Install production dependencies
RUN echo "Installing production dependencies..." && \
    /py/bin/pip install -r /tmp/requirements.txt

# Step 7: Install development dependencies if DEV=true
RUN echo "Checking if DEV mode is enabled..." && \
    if [ $DEV = "true" ]; then \
        echo "Installing development dependencies..." && \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    else \
        echo "Skipping development dependencies."; \
    fi

# Step 8: Cleanup temporary files and dependencies
RUN echo "Cleaning up..." && \
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Step 9: Add a non-root user
RUN echo "Creating non-root user..." && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"
USER django-user
