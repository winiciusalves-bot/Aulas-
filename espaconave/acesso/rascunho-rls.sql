-- RASCUNHO para revisão. NÃO aplicado no banco.
-- Objetivo: cada responsável (usuário autenticado) vê e altera só o próprio registro da criança.
-- Nenhuma criança cria conta sozinha. Nenhum dado além do primeiro nome e da skin.

create table if not exists public.acessos_crianca (
  id uuid primary key default gen_random_uuid(),
  responsavel_id uuid not null references auth.users(id) on delete cascade,
  primeiro_nome text not null check (char_length(primeiro_nome) between 1 and 30),
  skin jsonb not null default '{}'::jsonb,
  criado_em timestamptz not null default now()
);

alter table public.acessos_crianca enable row level security;

-- Responsável vê só os próprios registros
create policy "responsavel le o proprio" on public.acessos_crianca
  for select to authenticated
  using (responsavel_id = auth.uid());

-- Responsável cria registro só em seu nome
create policy "responsavel cria o proprio" on public.acessos_crianca
  for insert to authenticated
  with check (responsavel_id = auth.uid());

-- Responsável altera só os próprios
create policy "responsavel altera o proprio" on public.acessos_crianca
  for update to authenticated
  using (responsavel_id = auth.uid())
  with check (responsavel_id = auth.uid());

-- Responsável apaga só os próprios
create policy "responsavel apaga o proprio" on public.acessos_crianca
  for delete to authenticated
  using (responsavel_id = auth.uid());

-- Anônimos (sem login): nada. Sem policy para anon = sem acesso.
