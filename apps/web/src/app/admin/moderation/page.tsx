'use client'
import { useEffect, useState } from 'react'

export default function Moderation() {
const [items, setItems] = useState<any[]>([])
useEffect(() => {
(async () => {
const res = await fetch(${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/mod/queue, {
headers: { Authorization: Bearer ${localStorage.getItem('token') || ''} }
})
if (res.ok) setItems(await res.json())
})()
}, [])

return (
<div className="container mx-auto py-8">
<h1 className="text-2xl font-bold mb-4">Moderation Queue</h1>
{items.length === 0 ? <p>No reports.</p> : (
<ul className="space-y-3">
{items.map((r:any)=>(
<li key={r.id} className="border rounded p-3">
<div className="text-sm text-gray-500">{r.target_type} · {r.target_id}</div>
<div>{r.reason}</div>
</li>
))}
</ul>
)}
</div>
)
}
