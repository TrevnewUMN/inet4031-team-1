import uuid


def test_health_returns_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_create_incident_requires_title_and_status(client):
    response = client.post("/incidents", json={"title": "missing status"})
    assert response.status_code == 400
    assert "required" in response.get_json()["error"]


def test_create_then_list_incident(client):
    title = f"ci-test-{uuid.uuid4().hex[:8]}"
    created = client.post(
        "/incidents",
        json={"title": title, "status": "open", "description": "created by pytest"},
    )
    assert created.status_code == 201
    body = created.get_json()
    assert body["title"] == title
    assert body["status"] == "open"

    listed = client.get("/incidents")
    assert listed.status_code == 200
    assert any(incident["title"] == title for incident in listed.get_json())


def test_metrics_endpoint_is_exposed(client):
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"flask_http_request_duration_seconds" in response.data
