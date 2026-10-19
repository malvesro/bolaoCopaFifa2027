import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Página não encontrada',
};

export default function NotFound() {
  return (
    <div style={{ maxWidth: '600px', margin: '2rem auto', textAlign: 'center', padding: '2rem' }}>
      <h1 style={{ fontSize: '3rem', color: '#ef4444', marginBottom: '1rem' }}>404</h1>
      <h2 style={{ fontSize: '1.5rem', color: '#1e293b', marginBottom: '1rem' }}>
        Página não encontrada
      </h2>
      <p style={{ color: '#64748b', marginBottom: '2rem' }}>
        A página que você está procurando não existe ou foi movida.
      </p>
      <a
        href="/"
        style={{
          display: 'inline-block',
          padding: '0.75rem 1.5rem',
          backgroundColor: '#1e40af',
          color: 'white',
          textDecoration: 'none',
          borderRadius: '6px',
          fontWeight: 500
        }}
      >
        Voltar para início
      </a>
    </div>
  );
}
