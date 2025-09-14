'use client'
import { useEffect, useState } from 'react'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export default function Mood() {
const [posts, setPosts] = useState<any[]>([])
const [text, setText] = useState('')

const load = async () => setPosts(await api.request('/mood'))

useEffect(() => { load() }, [])

return (
<div className="container mx-auto py-8 space-y-6">
<h1 className="text-2xl font-bold">Mood & Thoughts</h1>
<form onSubmit={async (e)=>{ e.preventDefault(); await api.request('/mood',{method:'POST', body: JSON.stringify({text})}); setText(''); load()}} className="flex gap-2">
<Input placeholder="Share a thought…" value={text} onChange={e=>setText(e.target.value)} />
<Button type="submit">Post</Button>
</form>
<div className="space-y-4">
{posts.map(p=>(
<div key={p.id} className="border rounded p-4">
<div className="text-sm text-gray-500">{new Date(p.created_at).toLocaleString()}</div>
<div>{p.text}</div>
</div>
))}
</div>
</div>
)
}
