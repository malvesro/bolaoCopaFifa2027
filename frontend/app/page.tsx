import Link from 'next/link';

export default function HomePage() {
  return (
    <div style={{ maxWidth: '800px', margin: '0 auto' }}>
      <div style={{ backgroundColor: 'white', borderRadius: '8px', padding: '2rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', marginBottom: '2rem' }}>
        <h2 style={{ color: '#1e40af', marginTop: 0, fontSize: '2rem' }}>
          Bolão da Copa do Mundo Feminina da FIFA Brasil 2027™
        </h2>

        <div style={{ backgroundColor: '#fef3c7', border: '1px solid #f59e0b', borderRadius: '6px', padding: '1rem', marginBottom: '1.5rem' }}>
          <strong style={{ color: '#92400e' }}>⚠️ Ambiente de Desenvolvimento — Scaffold Inicial</strong>
          <p style={{ margin: '0.5rem 0 0 0', color: '#92400e' }}>
            Esta é uma interface inicial para validação do setup do projeto. Funcionalidades de negócio ainda não foram implementadas.
          </p>
        </div>

        <section style={{ marginBottom: '2rem' }}>
          <h3 style={{ color: '#1e293b', fontSize: '1.25rem', marginBottom: '1rem' }}>
            Informações do Projeto
          </h3>
          <ul style={{ lineHeight: '1.6', paddingLeft: '1.5rem' }}>
            <li><strong>Competição:</strong> Copa do Mundo Feminina da FIFA 2027</li>
            <li><strong>Local:</strong> Brasil</li>
            <li><strong>Seleções:</strong> 32 seleções participantes</li>
            <li><strong>Jogos:</strong> 64 partidas</li>
            <li><strong>Fuso Horário Oficial:</strong> BRT (UTC-3)</li>
            <li><strong>Corte de Palpites:</strong> 1 hora antes do kickoff oficial</li>
          </ul>
        </section>

        <section>
          <h3 style={{ color: '#1e293b', fontSize: '1.25rem', marginBottom: '1rem' }}>
            Links para Desenvolvedores
          </h3>
          <div style={{ display: 'grid', gap: '0.5rem' }}>
            <Link
              href="http://localhost:8000"
              style={{
                display: 'inline-block',
                padding: '0.75rem 1rem',
                backgroundColor: '#1e40af',
                color: 'white',
                textDecoration: 'none',
                borderRadius: '6px',
                fontWeight: 500
              }}
            >
              API Backend (http://localhost:8000)
            </Link>
            <Link
              href="http://localhost:8000/docs"
              style={{
                display: 'inline-block',
                padding: '0.75rem 1rem',
                backgroundColor: '#059669',
                color: 'white',
                textDecoration: 'none',
                borderRadius: '6px',
                fontWeight: 500
              }}
            >
              Swagger OpenAPI (http://localhost:8000/docs)
            </Link>
            <Link
              href="http://localhost:8000/live"
              style={{
                display: 'inline-block',
                padding: '0.75rem 1rem',
                backgroundColor: '#7c3aed',
                color: 'white',
                textDecoration: 'none',
                borderRadius: '6px',
                fontWeight: 500
              }}
            >
              Healthcheck (http://localhost:8000/live)
            </Link>
          </div>
          <p style={{ fontSize: '0.875rem', color: '#64748b', marginTop: '1rem' }}>
            <em>Nota: Links acima funcionam quando o backend está rodando localmente via Docker Compose</em>
          </p>
        </section>
      </div>

      <div style={{ textAlign: 'center', color: '#64748b', fontSize: '0.875rem' }}>
        <p>Scaffold inicial criado para Bolão Copa FIFA 2027 • Next.js 14 + TypeScript</p>
      </div>
    </div>
  );
}
