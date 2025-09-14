# Data Model (key tables)
- users, invites, ideas (+stems), playlists (+items), mood_posts, reports, takedowns, audit_events, refresh_tokens.
Indexes: ideas.parent_id, ideas.created_at, FTS planned on ideas.title+text.
