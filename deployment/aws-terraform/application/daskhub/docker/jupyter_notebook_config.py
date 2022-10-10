import logging
import os
from s3contents import S3ContentsManager

logger = logging.getLogger(__name__)

fulluser = os.environ['JUPYTERHUB_USER']
ix = fulluser.find('@')
if ix != -1:
    fulluser = fulluser[:ix]

c = get_config()

# Tell Jupyter to use S3ContentsManager
c.ServerApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = "jupyterhub-notebook-storage"
c.S3ContentsManager.prefix = fulluser
logger.debug(f'Configured S3ContentsManager for bucket={c.S3ContentsManager.bucket} and prefix={fulluser}')

# Fix JupyterLab dialog issues
#c.ServerApp.root_dir = ""

assert False
