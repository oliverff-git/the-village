'use client'

import { useEffect, useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/api'

export default function InvitePage({ params }: { params: { token: string } }) {
const router = useRouter()
const [validating, setValidating] = useState(true)
const [valid, setValid] = useState(false)
const [error, setError] = useState('')

const validateInvite = useCallback(async () => {
try {
await api.validateInvite(params.token)
setValid(true)
} catch {
setError('This invite is invalid or has expired')
} finally {
setValidating(false)
}
}, [params.token])

useEffect(() => { validateInvite() }, [validateInvite])

if (validating) {
return <div className="flex min-h-screen items-center justify-center"><p>Validating invite...</p></div>
}

if (!valid) {
return (
<div className="flex min-h-screen items-center justify-center">
<div className="text-center space-y-4">
<h1 className="text-2xl font-bold">Invalid Invite</h1>
<p className="text-muted-foreground">{error}</p>
<Button onClick={() => router.push('/')}>Return Home</Button>
</div>
</div>
)
}

return (
<div className="flex min-h-screen items-center justify-center">
<div className="text-center space-y-4 max-w-md">
<h1 className="text-2xl font-bold">Welcome to The Village!</h1>
<p className="text-muted-foreground">You&apos;ve been invited to join our creative community. Click below to create your account.</p>
<Button onClick={() => router.push(`/auth/register?token=${params.token}`)}>Create Account</Button>
</div>
</div>
)
}
