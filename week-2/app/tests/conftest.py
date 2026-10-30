import os
import sys

import pytest

# Let the tests import app.py from the folder above.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


@pytest.fixture()
def client():
    # app.py needs DATABASE_URL and creates the incidents table on import.
    # In CI it points at the PostgreSQL service container.
    import app as flask_app

    flask_app.app.config["TESTING"] = True
    with flask_app.app.test_client() as test_client:
        yield test_client
