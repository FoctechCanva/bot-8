FROM php:8.2-apache

# Install required extensions
RUN docker-php-ext-install pdo_mysql

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install dos2unix for line ending conversion
RUN apt-get update && apt-get install -y dos2unix

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Convert line endings to LF (Unix) and verify file existence
RUN dos2unix entrypoint.sh && \
    test -f entrypoint.sh || { echo "ERROR: entrypoint.sh missing!"; exit 1; } && \
    file entrypoint.sh | grep -q "CRLF" && { echo "ERROR: CRLF detected in entrypoint.sh"; exit 1; }

# Set file permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod 664 users.json error.log \
    && chmod +x entrypoint.sh

# Configure Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Entrypoint configuration
ENTRYPOINT ["./entrypoint.sh"]
