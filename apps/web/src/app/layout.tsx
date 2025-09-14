import './globals.css'
import Link from 'next/link'

export default function RootLayout({ children }: { children: React.ReactNode }) {
return (
<html lang="en">
<body>
<header className="border-b">
<div className="container mx-auto flex items-center justify-between p-4">
<Link href="/feed" className="font-bold">The Village</Link>
<nav className="text-sm space-x-4">
<Link href="/ideas/new">Share</Link>
<Link href="/mood">Mood</Link>
<Link href="/playlists">Playlists</Link>
</nav>
</div>
</header>
<main>{children}</main>
</body>
</html>
)
}
