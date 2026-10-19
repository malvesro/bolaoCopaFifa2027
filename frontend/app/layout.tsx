import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Bolão Copa do Mundo Feminina da FIFA 2027™',
  description: 'Plataforma de palpites para a Copa do Mundo Feminina da FIFA Brasil 2027™',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, sans-serif', backgroundColor: '#f8fafc', color: '#1e293b' }}>
        <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
          <header style={{ backgroundColor: '#1e40af', color: 'white', padding: '1rem 2rem', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
            <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 600 }}>
              Bolão Copa do Mundo Feminina da FIFA 2027™
            </h1>
          </header>
          <main style={{ flex: 1, padding: '2rem' }}>
            {children}
          </main>
          <footer style={{ backgroundColor: '#1e293b', color: 'white', padding: '1rem 2rem', textAlign: 'center', fontSize: '0.875rem' }}>
            © 2027 Bolão Copa do Mundo Feminina da FIFA Brasil
          </footer>
        </div>
      </body>
    </html>
  );
}
