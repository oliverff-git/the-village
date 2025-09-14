def auth(client, email="u3@example.com", handle="u3"):
client.post("/auth/register", json={"email": email, "handle": handle, "password": "password123", "age_confirmed": True})
tok = client.post("/auth/login", json={"email": email, "password": "password123"}).json()["access_token"]
return {"Authorization": f"Bearer {tok}"}

def test_create_and_fork_with_by_sa_propagation(client):
hdrs = auth(client)
# Parent BY-SA
p = client.post(
"/ideas/",
json={"type": "text", "title": "BYSA parent", "text": "t", "license": "CC_BY_SA_4_0", "visibility": "members"},
headers=hdrs,
).json()

# Try to fork with CC BY (should be forced to BY-SA)
f = client.post(f"/ideas/{p['id']}/fork", json={"license": "CC_BY_4_0", "title": "child"}, headers=hdrs).json()
assert f["license"] == "CC_BY_SA_4_0"
