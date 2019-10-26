FROM ubuntu
# -- Setup volume for output
VOLUME /opt/robotframework/reports
# -- For Execution Library
ENV XVFB_VERSION 1.20
# -- Frameworks
RUN apt-get update \
    && apt-get install -y python3 python3-pip firefox zip \
    # -- Chrome dependencies
    fonts-liberation libappindicator3-1 libnspr4 libnss3 libxss1 xdg-utils
# -- Dependencies & Clean up
RUN apt-get install -y wget xauth xvfb \
    && rm -rf /var/lib/apt/lists/*
# -- Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920
# -- Set number of threads for parallel execution
# -- By default, no parallelisation
ENV ROBOT_THREADS 1
# -- Libraries
ENV ROBOT_FRAMEWORK_VERSION 3.1.2
ENV FAKER_VERSION 4.2.0
ENV DATABASE_LIBRARY_VERSION 1.2
ENV SELENIUM_LIBRARY_VERSION 4.0.0
ENV PYMSSQL_VERSION 2.1.4
# -- Browsers
ENV CHROMIUM_VERSION 77.0
ENV FIREFOX_VERSION 70.0
ENV GECKO_DRIVER_VERSION v0.22.0
# -- Extras
ENV SSH_LIBRARY_VERSION 3.4.0 
#ENV FTP_LIBRARY_VERSION 1.6
# -- For parallelisation
ENV PABOT_VERSION 0.91
#ENV REQUESTS_VERSION 0.6.2
# -- Install libraries
RUN pip3 install \ 
    --no-cache-dir \
    robotframework==$ROBOT_FRAMEWORK_VERSION \
    robotframework-databaselibrary==$DATABASE_LIBRARY_VERSION \
    robotframework-faker==$FAKER_VERSION \
    robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
    robotframework-sshlibrary==$SSH_LIBRARY_VERSION \
    robotframework-pabot==$PABOT_VERSION \
    pymssql==$PYMSSQL_VERSION \
    PyYAML
# Download Gecko drivers directly from the GitHub repository
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
    && tar xzf geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \
    && mkdir -p /opt/robotframework/drivers/ \
    && mv geckodriver /opt/robotframework/drivers/geckodriver \
    && rm geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz
# Chrome Drivers
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	&& dpkg -i google-chrome*.deb \
	&& rm google-chrome*.deb
RUN wget https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip \
	&& unzip chromedriver_linux64.zip \
	&& rm chromedriver_linux64.zip \
	&& mv chromedriver /usr/local/bin \
	&& chmod +x /usr/local/bin/chromedriver
# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/chromium-browser.sh /opt/robotframework/bin/chromium-browser
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/
# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH
# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]