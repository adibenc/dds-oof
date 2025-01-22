FROM onlyoffice/documentserver:8.2

# Set timezone
ENV TZ=Asia/Jakarta
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Install additional libraries if needed (example)
# RUN apt-get update && apt-get install -y <package_name>

# Copy custom configuration files if needed
# COPY ./custom_config /opt/onlyoffice/DocumentServer/

# Expose necessary ports (already done in docker-compose)


#Optional:  Copy a custom startup script if necessary

#COPY ./entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]