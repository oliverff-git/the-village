"""init

Revision ID: 0001
Revises:
Create Date: 2025-01-01 12:00:00.000000
"""
from alembic import op
import sqlalchemy as sa # noqa: F401

# revision identifiers
revision = '0001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Tables are created by Base.metadata.create_all in main.py (dev)
    pass

def downgrade() -> None:
    pass
