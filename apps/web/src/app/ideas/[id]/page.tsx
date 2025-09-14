'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function IdeaDetail() {
const params = useParams<{ id: string }>()
const [idea, setIdea] = useState<any | null>(null)

useEffect(() => {
(async () => {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${params.id}`, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token') || ''}` }
  })
if (res.ok) setIdea(await res.json())
})()
}, [params.id])

if (!idea) return <div className="container mx-auto py-8">Loading…</div>

return (
<div className="container mx-auto py-8 space-y-4">
<h1 className="text-2xl font-bold">{idea.title}</h1>
{idea.text && <p className="text-gray-700">{idea.text}</p>}
<div className="flex items-center gap-2 text-sm">
<span className="px-2 py-1 rounded bg-gray-100">{idea.license}</span>
<span className="text-gray-500">{idea.type}</span>
</div>
<div className="flex gap-2">
<Button onClick={async () => {
  await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/ideas/${idea.id}/fork`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ license: idea.license })
  })
  window.location.href = '/feed'
}}>Fork</Button>
<Link href="/feed"><Button>Back</Button></Link>
</div>
</div>
)
}
