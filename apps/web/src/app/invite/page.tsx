'use client'
import { useState } from 'react'
import { api } from '@/lib/api'
import { Button } from '@/components/ui/button'

export default function InviteIndex() {
const [link, setLink] = useState<string | null>(null)
const [wa, setWa] = useState<string | null>(null)

return (
<div className="container mx-auto py-8 space-y-4">
<h1 className="text-2xl font-bold">Invite a friend</h1>
<Button onClick={async ()=>{
const inv = await api.createInvite()
const url = `${window.location.origin}/invite/${inv.token}`
setLink(url)
const msg = encodeURIComponent(`Join The Village: ${url}`)
setWa(`https://wa.me/?text=${msg}`)
}}>Generate Invite</Button>

  {link && (
    <div className="space-y-2">
      <div className="text-sm">Invite link:</div>
      <code className="block p-2 bg-gray-100 rounded">{link}</code>
      <a href={wa!} className="inline-block underline text-blue-600" target="_blank" rel="noreferrer">Share via WhatsApp</a>
    </div>
  )}
</div>
)
}
