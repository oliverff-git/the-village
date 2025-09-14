def test_register_login_flow(client):
    # register
    r = client.post(
        "/auth/register",
        json={"email": "u1@example.com", "handle": "u1", "password": "password123", "age_confirmed": True},
    )
    assert r.status_code == 200
    # login
    r = client.post("/auth/login", json={"email": "u1@example.com", "password": "password123"})
    assert r.status_code == 200
    tok = r.json()["access_token"]
    assert tok

def test_invite_create_and_validate(client):
    # seed user
    client.post(
        "/auth/register",
        json={"email": "u2@example.com", "handle": "u2", "password": "password123", "age_confirmed": True},
    )
    tok = client.post("/auth/login", json={"email": "u2@example.com", "password": "password123"}).json()["access_token"]
    # create invite
    r = client.post("/invites/", headers={"Authorization": f"Bearer {tok}"})
    assert r.status_code == 200
    token = r.json()["token"]
    # validate invite
    r = client.post(f"/invites/join/{token}")
    assert r.status_code == 200
    assert r.json()["ok"] is True
