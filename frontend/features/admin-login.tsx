'use client';

import { FormEvent, useEffect, useState } from 'react';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000';

type SessionResponse = { username: string };

export default function AdminLogin() {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('');
  const [authenticated, setAuthenticated] = useState(false);
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    fetch(`${API_URL}/admin/session`, { credentials: 'include' })
      .then(async (response) => {
        if (response.ok) {
          const session = (await response.json()) as SessionResponse;
          setAuthenticated(session.username === 'admin');
        }
      })
      .catch(() => setMessage('Não foi possível conectar à API local.'));
  }, []);

  async function handleLogin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBusy(true);
    setMessage('');
    try {
      const response = await fetch(`${API_URL}/admin/session`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ username, password }),
      });
      if (!response.ok) {
        setMessage(response.status === 404 ? 'Login local indisponível neste ambiente.' : 'Credenciais inválidas.');
        return;
      }
      setPassword('');
      setAuthenticated(true);
      setMessage('Sessão administrativa local iniciada.');
    } catch {
      setMessage('Não foi possível conectar à API local.');
    } finally {
      setBusy(false);
    }
  }

  async function handleLogout() {
    setBusy(true);
    setMessage('');
    try {
      const response = await fetch(`${API_URL}/admin/session`, { method: 'DELETE', credentials: 'include' });
      if (!response.ok) {
        setMessage('Não foi possível confirmar o encerramento da sessão.');
        return;
      }
      setAuthenticated(false);
      setMessage('Sessão encerrada.');
    } catch {
      setMessage('Não foi possível conectar à API; o encerramento da sessão não foi confirmado.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <section aria-labelledby="admin-login-title" style={{ marginTop: '2rem', padding: '1.5rem', background: 'white', borderRadius: '8px' }}>
      <h3 id="admin-login-title">Administração local</h3>
      {authenticated ? (
        <div>
          <p role="status">Autenticado como administrador local.</p>
          <button type="button" onClick={handleLogout} disabled={busy}>{busy ? 'Encerrando…' : 'Encerrar sessão'}</button>
        </div>
      ) : (
        <form onSubmit={handleLogin}>
          <label htmlFor="admin-username">Usuário</label>
          <input id="admin-username" autoComplete="username" value={username} onChange={(event) => setUsername(event.target.value)} required />
          <label htmlFor="admin-password">Senha</label>
          <input id="admin-password" type="password" autoComplete="current-password" value={password} onChange={(event) => setPassword(event.target.value)} required />
          <button type="submit" disabled={busy}>{busy ? 'Entrando…' : 'Entrar'}</button>
        </form>
      )}
      {message && <p role="status">{message}</p>}
      <p>Disponível apenas no ambiente local de desenvolvimento.</p>
    </section>
  );
}
