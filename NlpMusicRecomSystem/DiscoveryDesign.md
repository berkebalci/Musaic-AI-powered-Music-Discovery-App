---
name: Atmospheric Noir
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bec8d0'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#88929a'
  outline-variant: '#3e484f'
  surface-tint: '#7bd0ff'
  primary: '#a4ddff'
  on-primary: '#003549'
  primary-container: '#57c5fb'
  on-primary-container: '#00506d'
  inverse-primary: '#00668a'
  secondary: '#c0c1ff'
  on-secondary: '#1000a9'
  secondary-container: '#3131c0'
  on-secondary-container: '#b0b2ff'
  tertiary: '#62ebd7'
  on-tertiary: '#003731'
  tertiary-container: '#3ecebb'
  on-tertiary-container: '#00544b'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c3e7ff'
  primary-fixed-dim: '#7bd0ff'
  on-primary-fixed: '#001e2c'
  on-primary-fixed-variant: '#004c69'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#71f8e4'
  tertiary-fixed-dim: '#4fdbc8'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005048'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
  midnight-bg: '#0B0F19'
  glass-surface: rgba(30, 41, 59, 0.4)
  border-translucent: rgba(255, 255, 255, 0.12)
  glow-cyan: rgba(87, 197, 251, 0.3)
  text-muted: '#94A3B8'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  metadata:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is centered on a "Premium AI-Curated" persona, evoking a sense of calm, intelligence, and immersive focus. The brand personality is sophisticated and ethereal, moving away from high-energy vibrance toward a serene, "late-night" digital sanctuary.

The visual style is a refined **Glassmorphism**, characterized by heavy background blurs, ultra-thin translucent borders, and soft glowing accents. It draws inspiration from high-end iOS aesthetics, prioritizing depth and tactility through layered light rather than physical texture. The emotional response should be one of "effortless discovery," where the UI feels like a gentle, glowing guide through a vast musical landscape.

## Colors

The palette is a deep monochromatic blue system designed for low-light, high-contrast environments. 

- **Primary (Soft Cyan):** Reserved for high-priority actions, play states, and primary CTAs. It represents "Light" and "Activity."
- **Secondary (Indigo):** Used for mood-based gradients and secondary interactive elements, bridging the gap between the background and active accents.
- **Tertiary (Teal):** Used specifically for active state feedback and "mood" progress indicators.
- **Neutral (Midnight):** A layered set of deep navy hues that form the foundation of the UI.

The system relies on "Atmospheric Gradients" (Indigo to Teal) to signify AI-generated or emotional content areas, creating a distinction between the rigid app chrome and the fluid music content.

## Typography

This design system utilizes **Inter** (as a high-fidelity alternative to SF Pro) to maintain a clean, modernist aesthetic. 

- **Headlines:** Set in bold weights with tighter letter-spacing to create a strong visual anchor against the soft background blurs.
- **Metadata:** Smaller, high-contrast labels used for track info and timestamps.
- **Readability:** All text must maintain a minimum 4.5:1 contrast ratio. On glassmorphic surfaces, use "Vibrant" text rendering (semi-transparent white) only for secondary information; primary labels must remain solid white (#FFFFFF).

## Layout & Spacing

The layout follows a **Fluid Grid** model with generous safe margins (24px) to ensure the content feels "floating" rather than cramped. 

- **Rhythm:** An 8px linear scale governs all padding and margins.
- **Mobile:** Elements are primarily stacked vertically. The "Music Player Bar" is a persistent glassmorphic element docked at the bottom, sitting 8px above the home indicator.
- **Desktop/Tablet:** Content expands into a multi-column masonry grid for discovery tiles, but maintain a maximum content width of 1200px to preserve focus.

## Elevation & Depth

Depth is conveyed through **Glassmorphism** and **Tonal Layering** rather than traditional drop shadows.

- **Background:** A deep midnight blue base.
- **Layer 1 (Cards/Panels):** `surface-glass` with a 20px - 40px backdrop blur and a 1px `border-translucent` stroke.
- **Layer 2 (Popovers/Overlays):** Higher opacity glass with a subtle `glow-cyan` outer glow (blur: 20px, spread: -5px) to indicate "Active" focus.
- **Glow Accents:** Icons and buttons emit a soft radiance onto the layers beneath them, simulating a physical light source in a dark room.

## Shapes

The shape language is consistently "Rounded" (0.5rem base) to maintain the "Soft Blue" approachable theme. 

- **Cards and Containers:** Use `rounded-lg` (16px) or `rounded-xl` (24px) to emphasize the soft, fluid nature of the glass panels.
- **Input Fields:** Semi-oval shapes (12px radius) are preferred to align with the iOS-inspired aesthetic.
- **Buttons:** Fully pill-shaped for primary actions to provide maximum touch-target clarity and contrast against rectangular cards.

## Components

### Buttons
- **Primary:** Solid `accent-primary` (Cyan) with white text. Apply a subtle 8px cyan outer glow when in an "Active/Playing" state.
- **Ghost:** Transparent background with a `border-translucent` stroke. Text inherits the `accent-primary` color.

### Glass Message Bubbles
- Used for AI recommendations. Features 30px backdrop blur, `surface-glass` background, and a top-left light-source highlight (a 1px white gradient border).

### Input Bar
- Minimalist, semi-transparent bar. When focused, the border transitions from `border-translucent` to solid `accent-primary` with a 4px soft outer glow.

### Chips
- Rounded pill shapes used for "Mood Tags." Background is a very low opacity Indigo; active states transition to a Teal-to-Cyan gradient.

### Music Player Bar
- A persistent glassmorphic dock. Includes a progress bar that uses a glowing Teal line against a semi-transparent white track.

### Cards
- Interactive tiles for albums/playlists. No shadows; instead, use a 1px inner stroke and a high-blur background to separate the card from the midnight backdrop.