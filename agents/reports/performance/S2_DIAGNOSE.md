# Diagnostic Report - Performance & Architecture

## Component
API Performance - Database Queries and Architecture Patterns

## Purpose
Identify and resolve performance bottlenecks, inefficient queries, and architectural issues that could impact scalability.

## Boundaries/Dependencies
- **ORM**: SQLAlchemy with lazy loading
- **Database**: PostgreSQL
- **Caching**: None implemented
- **Background Jobs**: Redis Queue (RQ)

## Issue Summary
- Potential N+1 query problems
- Missing database indexes on queried fields
- No caching layer for repeated queries
- Inefficient pagination patterns
- No query optimization or eager loading

## Evidence
### Issue 1: N+1 Query Pattern in Ideas Listing
- **File(s)**: `apps/api/api/ideas.py`
- **Code**: Lines 24-46
  ```python
  @router.get("/", response_model=List[IdeaResponse])
  def list_ideas(...):
      query = db.query(Idea).filter(...)
      # Returns ideas without eager loading author/parent relationships
      return query.order_by(Idea.created_at.desc()).offset(skip).limit(limit).all()
  ```
- **Problem**: Each idea serialization may trigger separate queries for author data

### Issue 2: Unbounded Query in Mood Posts
- **File(s)**: `apps/api/api/mood.py`
- **Code**: Line 14
  ```python
  posts = db.query(MoodPost).order_by(MoodPost.created_at.desc()).limit(100).all()
  ```
- **Problem**: Always fetches 100 posts, no pagination support

### Issue 3: Missing Database Indexes
- **File(s)**: `apps/api/models/idea.py`
- **Indexed Fields**: Only title, created_at, parent_id
- **Missing Indexes**:
  - type (filtered in queries)
  - license (filtered in queries)
  - status + visibility (compound index for common filter)

### Issue 4: No Caching Implementation
- **Evidence**: No Redis cache usage despite Redis being available
- **Impact**: Database hit for every request
- **Common Queries**: User lookups, idea listings, permissions checks

### Issue 5: Inefficient Permission Checks
- **File(s)**: `apps/api/core/security.py`
- **Lines**: 75-101
- **Issue**: User fetched from DB on every authenticated request

## Reproduction Steps
```bash
# Monitor database queries
# Enable SQLAlchemy query logging
cd /Users/oliver/projects/the-village/apps/api
# Add to main.py: logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Load test ideas endpoint
ab -n 100 -c 10 -H "Authorization: Bearer TOKEN" http://localhost:8000/ideas/

# Check query patterns in logs
```

## Hypothesis
1. **ORM Defaults**: Using SQLAlchemy lazy loading without optimization
2. **MVP Speed**: Quick implementation without performance consideration
3. **Scale Assumptions**: Built for small user base initially
4. **Missing Monitoring**: No query performance tracking to identify issues

## Severity/Blast Radius
- **Severity**: Medium (will become High with scale)
- **Affected Components**: 
  - All list endpoints
  - Authentication middleware
  - Related object serialization
- **User Impact**: 
  - Slow API responses under load
  - Database connection exhaustion
  - Poor user experience at scale

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
