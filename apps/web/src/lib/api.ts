const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export interface LoginData { email: string; password: string }
export interface RegisterData {
email: string; handle: string; password: string; age_confirmed: boolean; invite_token?: string
}
export interface TokenResponse { access_token: string; refresh_token: string; token_type: string }

class ApiClient {
private token: string | null = null

setToken(token: string) {
this.token = token
if (typeof window !== 'undefined') localStorage.setItem('token', token)
}

getToken(): string | null {
if (typeof window !== 'undefined' && !this.token) this.token = localStorage.getItem('token')
return this.token
}

clearToken() {
this.token = null
if (typeof window !== 'undefined') {
localStorage.removeItem('token')
localStorage.removeItem('refresh_token')
}
}

async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
const url = ${API_URL}${endpoint}
const headers: HeadersInit = { 'Content-Type': 'application/json', ...(options.headers || {}) }
const tok = this.getToken()
if (tok) headers['Authorization'] = Bearer ${tok}
const response = await fetch(url, { ...options, headers })
if (!response.ok) {
if (response.status === 401) { this.clearToken(); if (typeof window !== 'undefined') window.location.href = '/auth/login' }
throw new Error(API Error: ${response.statusText})
}
return response.json()
}

async login(data: LoginData): Promise<TokenResponse> {
const res = await this.request<TokenResponse>('/auth/login', { method: 'POST', body: JSON.stringify(data) })
this.setToken(res.access_token)
if (typeof window !== 'undefined') localStorage.setItem('refresh_token', res.refresh_token)
return res
}

async register(data: RegisterData): Promise<any> {
return this.request('/auth/register', { method: 'POST', body: JSON.stringify(data) })
}

async getMe(): Promise<any> { return this.request('/auth/me') }

async getIdeas(params?: any): Promise<any> {
const qs = params ? ?${new URLSearchParams(params)} : ''
return this.request(/ideas${qs})
}

async createIdea(data: any): Promise<any> {
return this.request('/ideas', { method: 'POST', body: JSON.stringify(data) })
}

async forkIdea(ideaId: string): Promise<any> {
return this.request(/ideas/${ideaId}/fork, { method: 'POST', body: JSON.stringify({ license: 'CC_BY_4_0' }) })
}

async createInvite(): Promise<any> { return this.request('/invites', { method: 'POST' }) }
async validateInvite(token: string): Promise<any> { return this.request(/invites/join/${token}, { method: 'POST' }) }
}
export const api = new ApiClient()
