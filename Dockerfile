FROM python:2.7-slim

RUN apt-get update && \
    apt-get -y install expect-dev git wget npm && \
    pip install lxml

ENV VERSION="9.0"
ENV TRAVIS_BUILD_DIR="/tmp"

# Setup maintainer-quality-tools, a set of development tools maintained by ODOO
RUN git clone https://github.com/OCA/maintainer-quality-tools.git ${HOME}/maintainer-quality-tools && \
    export PATH=${HOME}/maintainer-quality-tools/travis:${PATH} && \
    travis_install_nightly

WORKDIR $HOME/odoo-$VERSION

# Expose ODOO port
EXPOSE 8069

CMD $HOME/odoo-$VERSION/./openerp-server --addons-path=$HOME/odoo-$VERSION/addons --db_user=travis --db_password=admin --db_host=localhost
