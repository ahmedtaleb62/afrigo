import type { ReactNode } from 'react'

export type AfrigoApp = 'client' | 'taxi' | 'food' | 'livreur'

const paths: Record<AfrigoApp, ReactNode> = {
  client: (
    <>
      <circle cx={36} cy={36} r={32} fill="#2AA35C" />
      <path
        d="M36 14 A22 22 0 0 1 58 36"
        stroke="#F5C518"
        strokeWidth={6}
        fill="none"
        strokeLinecap="round"
      />
      <circle cx={36} cy={36} r={10} fill="#fff" />
    </>
  ),
  taxi: (
    <>
      <rect x={4} y={4} width={64} height={64} rx={18} fill="#2AA35C" />
      <path d="M18 42 L24 30 Q26 26 32 26 L44 26 Q48 26 50 30 L54 42 Z" fill="#F5C518" />
      <rect x={16} y={42} width={40} height={8} rx={4} fill="#F5C518" />
      <circle cx={26} cy={52} r={5} fill="#0F3F23" />
      <circle cx={46} cy={52} r={5} fill="#0F3F23" />
    </>
  ),
  food: (
    <>
      <circle cx={36} cy={36} r={32} fill="#F5C518" />
      <circle cx={36} cy={38} r={16} fill="#fff" />
      <path
        d="M28 38 h16 M28 38 a8 5 0 0 0 16 0"
        stroke="#2AA35C"
        strokeWidth={3}
        fill="none"
        strokeLinecap="round"
      />
      <path d="M22 20 v8 M26 20 v8 M30 20 v8" stroke="#2AA35C" strokeWidth={3} strokeLinecap="round" />
    </>
  ),
  livreur: (
    <>
      <circle cx={36} cy={36} r={32} fill="#2AA35C" />
      <circle cx={24} cy={46} r={9} fill="none" stroke="#F5C518" strokeWidth={4} />
      <circle cx={48} cy={46} r={9} fill="none" stroke="#F5C518" strokeWidth={4} />
      <path
        d="M24 46 L34 28 L44 46 M34 28 L42 28 M24 46 L48 46"
        stroke="#fff"
        strokeWidth={3}
        fill="none"
        strokeLinecap="round"
      />
    </>
  ),
}

/** Renders the primary mark for one of the 4 Afrigo apps — pixel-identical
 * to the SVGs in `Afrigo Design System.dc.html` section 1. Mirrors
 * `AfrigoLogo` in `packages/afrigo_core`. */
export function Logo({ app, size = 32 }: { app: AfrigoApp; size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg">
      {paths[app]}
    </svg>
  )
}
