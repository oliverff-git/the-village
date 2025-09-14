'use client'

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'
import Link from 'next/link'

export default function FeedPage() {
const [ideas, setIdeas] = useState<any[]>([])
const [loading, setLoading] = useState(true)

useEffect(() => { loadIdeas() }, [])

const loadIdeas = async () => {
try {
const data = await api.getIdeas()
setIdeas(data)
} catch (err) {
console.error('Failed to load ideas:', err)
} finally {
setLoading(false)
}
}

const handleFork = async (ideaId: string) => {
try {
await api.forkIdea(ideaId)
loadIdeas()
} catch (err) {
console.error('Failed to fork idea:', err)
}
}

if (loading) return <div className="container mx-auto py-8"><p>Loading ideas...</p></div>

return (
<div className="container mx-auto py-8">
<div className="flex justify-between items-center mb-8">
<h1 className="text-3xl font-bold">The Village Feed</h1>
<Link href="/ideas/new"><Button>Share Idea</Button></Link>
</div>

  <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    {ideas.map((idea) => (
      <div key={idea.id} className="border rounded-lg p-6 space-y-4">
        <h2 className="text-xl font-semibold">{idea.title}</h2>
        {idea.text && <p className="text-muted-foreground">{idea.text}</p>}

        <div className="flex items-center justify-between text-sm">
          <span className="inline-flex items-center px-2 py-1 rounded-full text-xs bg-gray-100">
            {idea.license}
          </span>
          <span className="text-muted-foreground">{idea.type}</span>
        </div>

        {idea.parent_id && <div className="text-sm text-muted-foreground">Forked from another idea</div>}

        <div className="flex gap-2">
          <Button size="sm" onClick={() => handleFork(idea.id)}>Fork</Button>
          <Link href={`/ideas/${idea.id}`}><Button size="sm">View</Button></Link>
        </div>
      </div>
    ))}
  </div>

  {ideas.length === 0 && <div className="text-center py-12"><p className="text-muted-foreground">No ideas yet. Be the first to share!</p></div>}
</div>
)
}
