import { useCallback, useEffect, useState } from 'react'

const STORAGE_KEY = 'afrigo-admin-dark'

function readInitial(): boolean {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored !== null) return stored === '1'
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

/** Toggles the `.dark` class on `<html>` (matches index.css's `@custom-variant dark`). */
export function useDarkMode() {
  const [dark, setDark] = useState(readInitial)

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem(STORAGE_KEY, dark ? '1' : '0')
  }, [dark])

  const toggle = useCallback(() => setDark((d) => !d), [])

  return { dark, toggle }
}
