'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function RegisterPage() {
const router = useRouter()
const searchParams = useSearchParams()
const inviteToken = searchParams.get('token')

const [email, setEmail] = useState('')
const [handle, setHandle] = useState('')
const [password, setPassword] = useState('')
const [ageConfirmed, setAgeConfirmed] = useState(false)
const [error, setError] = useState('')
const [loading, setLoading] = useState(false)

const handleSubmit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
setLoading(true)

if (!ageConfirmed) {
  setError('You must be 18 or older to use The Village')
  setLoading(false)
  return
}

try {
  await api.register({ email, handle, password, age_confirmed: ageConfirmed, invite_token: inviteToken || undefined })
  await api.login({ email, password })
  router.push('/feed')
} catch (err: any) {
  setError(err.message || 'Registration failed')
} finally {
  setLoading(false)
}
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="w-full max-w-md space-y-8 p-8">
<div className="text-center">
<h1 className="text-2xl font-bold">Join The Village</h1>
<p className="text-muted-foreground mt-2">Create your account to start sharing</p>
</div>

    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      </div>

      <div>
        <Label htmlFor="handle">Handle</Label>
        <Input id="handle" value={handle} onChange={(e) => setHandle(e.target.value)} placeholder="@yourhandle" required />
      </div>

      <div>
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      </div>

      <div className="flex items-center space-x-2">
        <input type="checkbox" id="age" checked={ageConfirmed} onChange={(e) => setAgeConfirmed(e.target.checked)} className="rounded border-gray-300" />
        <Label htmlFor="age" className="text-sm">I confirm that I am 18 years or older</Label>
      </div>

      {error && <div className="text-sm text-red-600">{error}</div>}
      <Button type="submit" className="w-full" disabled={loading}>{loading ? 'Creating account...' : 'Create account'}</Button>
    </form>
  </div>
</div>
)
}
