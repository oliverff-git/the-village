from fastapi import APIRouter

router = APIRouter()

docs = {
"terms": "# Terms\nSee docs/TERMS.md in the repo.",
"privacy": "# Privacy\nSee docs/PRIVACY.md.",
"charter": "# Village Charter\nShare generously. Credit upstream.",
"notice-takedown": "# Notice & Takedown\nEmail takedown@thevillage.local with details.",
"illegal-content": "# Illegal Content Policy\nWe remove illegal content swiftly.",
"licenses": "# Licences\nCC0, CC BY 4.0, CC BY-SA 4.0",
}

@router.get("/{slug}")
def get_legal(slug: str):
    return {"slug": slug, "markdown": docs.get(slug, "# Not found")}
