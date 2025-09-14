'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'

export default function NewIdea() {
const router = useRouter()
const [title, setTitle] = useState('')
const [text, setText] = useState('')
const [type, setType] = useState<'text'|'image'|'audio'|'video'>('text')
const [license, setLicense] = useState<'CC0'|'CC_BY_4_0'|'CC_BY_SA_4_0'>('CC0')
const [error, setError] = useState<string>('')

const submit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
try {
await api.createIdea({ type, title, text: type === 'text' ? text : undefined, license })
router.push('/feed')
} catch (err: any) {
setError(err.message ?? 'Failed to create idea')
}
}

return (
<div className="container mx-auto max-w-2xl py-8">
<h1 className="text-2xl font-bold mb-6">Share an Idea</h1>
<form onSubmit={submit} className="space-y-4">
<div>
<Label>Type</Label>
<select value={type} onChange={e => setType(e.target.value as any)} className="border rounded p-2 w-full">
<option value="text">Text</option>
<option value="image">Image (URL later)</option>
<option value="audio">Audio (URL later)</option>
<option value="video">Video (URL later)</option>
</select>
</div>
<div>
<Label>Title</Label>
<Input value={title} onChange={e=>setTitle(e.target.value)} required />
</div>
{type === 'text' && (
<div>
<Label>Text</Label>
<textarea className="border rounded p-2 w-full min-h-[120px]" value={text} onChange={e=>setText(e.target.value)} />
</div>
)}
<div>
<Label>Licence</Label>
<select value={license} onChange={e => setLicense(e.target.value as any)} className="border rounded p-2 w-full">
<option value="CC0">CC0 (Public Domain)</option>
<option value="CC_BY_4_0">CC BY 4.0 (Credit required)</option>
<option value="CC_BY_SA_4_0">CC BY-SA 4.0 (ShareAlike)</option>
</select>
<p className="text-xs text-gray-500 mt-1">We disallow ND/NC. Share freely; credit where needed.</p>
</div>

    {error && <p className="text-red-600 text-sm">{error}</p>}
    <Button type="submit">Publish</Button>
  </form>
</div>
)
}
