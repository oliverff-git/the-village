'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api } from '@/lib/api'

export default function LoginPage() {
const router = useRouter()
const [email, setEmail] = useState('')
const [password, setPassword] = useState('')
const [error, setError] = useState('')
const [loading, setLoading] = useState(false)

const handleSubmit = async (e: React.FormEvent) => {
e.preventDefault()
setError('')
setLoading(true)
try {
await api.login({ email, password })
router.push('/feed')
} catch {
setError('Invalid email or password')
} finally {
setLoading(false)
}
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="w-full max-w-md space-y-8 p-8">
<div className="text-center">
<h1 className="text-2xl font-bold">Welcome back</h1>
<p className="text-muted-foreground mt-2">Sign in to your Village account</p>
</div>

    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      </div>

      <div>
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      </div>

      {error && <div className="text-sm text-red-600">{error}</div>}

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? 'Signing in...' : 'Sign in'}
      </Button>
    </form>

    <div className="text-center text-sm">
      <span className="text-muted-foreground">Don't have an account? </span>
      <Link href="/invite" className="text-blue-600 underline">Join with invite</Link>
    </div>
  </div>
</div>
)
}
