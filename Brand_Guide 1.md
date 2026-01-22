# Brand Guide
## AI Interior Design Automation and Auto Quote System

**Brand Name:** DesignQuote AI  
**Tagline:** "Design with Confidence. Quote in Minutes."  
**Design Inspiration:** Modern Interior Architect Agency Aesthetic  
**Last Updated:** January 20, 2026

---

## TABLE OF CONTENTS
1. [Brand Overview](#1-brand-overview)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Visual Style & Imagery](#4-visual-style--imagery)
5. [Logo & Branding](#5-logo--branding)
6. [Component Library](#6-component-library)
7. [Layout & Spacing](#7-layout--spacing)
8. [Photography & Imagery Guidelines](#8-photography--imagery-guidelines)
9. [Icon System](#9-icon-system)
10. [Tone & Voice](#10-tone--voice)

---

## 1. BRAND OVERVIEW

### 1.1 Brand Identity

**Brand Name:** DesignQuote AI  
**Industry:** Design Technology / SaaS  
**Target Audience:** Interior Designers, Design Studios, Architects  
**Brand Personality:** 
- Premium & Professional
- Modern & Sophisticated
- Approachable & Trustworthy
- Creative & Innovative

### 1.2 Brand Promise

"Empower interior designers with AI-driven precision. Transform how you quote. Elevate your business."

### 1.3 Brand Values

✓ **Excellence:** Premium quality in every detail  
✓ **Simplicity:** Complex made effortless  
✓ **Innovation:** AI-powered solutions  
✓ **Trust:** Reliable, accurate, professional  
✓ **Creativity:** Enable designer's artistic vision  

---

## 2. COLOR PALETTE

### 2.1 Primary Colors

**Deep Forest Green** (Primary Brand Color)
- Hex: `#4A6C5D` (or `#3D5A4F`)
- RGB: `74, 108, 93`
- CMYK: `32, 0, 14, 58`
- HSL: `151, 18%, 36%`
- Usage: Headlines, primary buttons, navigation, key elements
- Meaning: Growth, stability, nature, sophistication

**Warm Beige/Tan** (Accent Color)
- Hex: `#D4A574` (or `#C89968`)
- RGB: `212, 165, 116`
- CMYK: `0, 22, 45, 17`
- HSL: `28, 58%, 64%`
- Usage: Accents, highlights, calls-to-action, decorative elements
- Meaning: Warmth, natural, inviting, luxury

### 2.2 Secondary Colors

**Cream/Off-White** (Background)
- Hex: `#F8F6F1` (or `#F5F3F0`)
- RGB: `248, 246, 241`
- CMYK: `0, 1, 3, 3`
- HSL: `32, 37%, 96%`
- Usage: Page backgrounds, card backgrounds, minimal contrast
- Meaning: Clean, premium, elegant

**Charcoal Gray** (Dark Text)
- Hex: `#2B3E3A` (or `#1F1F1F`)
- RGB: `43, 62, 58`
- CMYK: `31, 0, 6, 76`
- HSL: `155, 18%, 21%`
- Usage: Body text, dark elements, depth
- Meaning: Professional, serious, grounded

**Light Gray** (Borders/Dividers)
- Hex: `#D9D6D1` (or `#E5E3E0`)
- RGB: `217, 214, 209`
- CMYK: `0, 1, 4, 15`
- HSL: `26, 11%, 83%`
- Usage: Borders, dividers, subtle backgrounds
- Meaning: Minimalist, clean, separation

### 2.3 Color Usage Chart

```
Primary Actions       → Deep Forest Green (#4A6C5D)
Secondary Actions    → Warm Beige (#D4A574)
Backgrounds          → Cream (#F8F6F1)
Text - Headings      → Charcoal Gray (#2B3E3A)
Text - Body          → Dark Gray (#5A5A5A)
Borders/Dividers     → Light Gray (#D9D6D1)
Success State        → Sage Green (#7A9A8C)
Warning State        → Warm Orange (#E6A757)
Error State          → Dusty Rose (#C08080)
```

### 2.4 Color Combinations

**Premium Pairing:**
- Forest Green + Warm Beige + Cream
- Creates sophisticated, upscale feeling

**Neutral Professional:**
- Charcoal Gray + Light Gray + Cream
- Clean, minimal, professional

**Warm Welcoming:**
- Warm Beige + Forest Green + Cream
- Inviting, premium, accessible

---

## 3. TYPOGRAPHY

### 3.1 Font Family

**Primary Font: "Geist" or "Inter" (Modern Sans-Serif)**
- Fallback: System fonts (-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif)
- Usage: All headings, buttons, navigation, primary UI
- Characteristics: Clean, modern, highly legible, professional

**Secondary Font: "Lora" or "Playfair Display" (Serif)**
- Usage: Elegant quotes, testimonials, featured sections
- Characteristics: Sophisticated, premium, editorial

**Monospace Font: "Fira Code" or "JetBrains Mono"**
- Usage: Code blocks, pricing, technical data
- Characteristics: Technical, precise, data-focused

### 3.2 Typography Scale

| Element | Size | Weight | Line Height | Letter Spacing |
|---------|------|--------|-------------|-----------------|
| **H1** (Hero) | 56px | 700 | 1.2 | -0.02em |
| **H2** (Section) | 40px | 600 | 1.3 | -0.01em |
| **H3** (Subsection) | 28px | 600 | 1.4 | 0 |
| **H4** (Card Title) | 20px | 600 | 1.5 | 0 |
| **H5** (Label) | 16px | 600 | 1.5 | 0.01em |
| **H6** (Small Label) | 14px | 600 | 1.5 | 0.02em |
| **Body Large** | 18px | 400 | 1.6 | 0 |
| **Body Regular** | 16px | 400 | 1.6 | 0 |
| **Body Small** | 14px | 400 | 1.5 | 0 |
| **Caption** | 12px | 400 | 1.5 | 0.01em |
| **Overline** | 12px | 700 | 1.5 | 0.1em |

### 3.3 Text Styles

```typescript
// Example CSS variables
--font-h1: 56px, 700, 1.2, -0.02em;
--font-h2: 40px, 600, 1.3, -0.01em;
--font-h3: 28px, 600, 1.4, 0;
--font-body: 16px, 400, 1.6, 0;
--font-caption: 12px, 400, 1.5, 0.01em;
```

### 3.4 Font Pairing Example

```css
/* Elegant heading + clean body text */
h1, h2, h3 { font-family: 'Geist', sans-serif; font-weight: 600; }
p, body { font-family: 'Geist', sans-serif; font-weight: 400; }
blockquote { font-family: 'Lora', serif; font-style: italic; }
```

---

## 4. VISUAL STYLE & IMAGERY

### 4.1 Design Aesthetic

**Key Visual Characteristics:**
- Circular/Oval Elements: Organic, modern, softens rigid layouts
- Layered Composition: Multiple depth layers for sophistication
- White Space: Generous spacing emphasizes premium feel
- Muted Color Tones: Sophisticated, not vibrant
- Natural Materials: Wood, stone, fabric textures
- Geometric Harmony: Balanced asymmetry

### 4.2 Layout Patterns

**1. Circular Image Treatments**
- Primary project images in perfect circles or organic ovals
- Creates visual interest and breaks monotony
- Softens the overall design
- Used for: Project showcases, before/after, testimonials

**2. Layered Stacking**
- Multiple images overlapping with subtle shadows
- Creates depth and visual hierarchy
- Professional gallery effect
- Used for: Project galleries, feature showcases

**3. Grid with Varied Sizing**
- Masonry-style layouts with different image sizes
- 2-3 column layouts for portfolio sections
- Maintains visual rhythm while showing diversity

**4. Hero Section with Imagery**
- Large hero image (or video background)
- Circular accent elements overlaying text
- Gradient or solid overlay for text readability

### 4.3 Visual Hierarchy Example

```
Hero Section:
├─ Large background image/video
├─ Circular accent images (foreground)
└─ Dark overlay text on light background

Portfolio Section:
├─ Grid layout (varying sizes)
├─ Circular thumbnail images
├─ Subtle shadows and depth
└─ Clean white space between items

Testimonials:
├─ Circular user avatars
├─ Serif typography for quotes
├─ Clean cards with light backgrounds
└─ Consistent spacing
```

---

## 5. LOGO & BRANDING

### 5.1 Logo Concept

**Design Direction:**
- Geometric circle or nested circles (representing layers/design phases)
- Integration of design + AI symbolism
- Minimalist, modern approach
- Monogram style for versatility

**Logo Variations:**

**Version 1: Geometric Circle**
```
Symbol: Overlapping circles or nested rings
Meaning: Layers of design, iterative process
Color: Forest Green
Variations: Monochrome, white, gradient
```

**Version 2: Design + Technology Fusion**
```
Symbol: Blend of protractor/ruler + digital wave
Meaning: Design meets AI/technology
Color: Forest Green with Warm Beige accent
Variations: Full color, monochrome, icon-only
```

### 5.2 Logo Usage

**Minimum Size:** 40px width (web), 0.5 inches (print)  
**Clear Space:** Minimum 10px padding around logo  
**Aspect Ratio:** 1:1 (square)  
**File Formats:** SVG (primary), PNG with transparency, EPS (print)

**Logo Versions:**

1. **Full Logo** (Horizontal)
   - Logo + Brand name
   - Primary use for headers, large spaces

2. **Icon Only** (Symbol)
   - Logo mark without text
   - Use for: Favicon, app icon, small spaces

3. **Stacked** (Vertical)
   - Logo above brand name
   - Use for: Social media profiles, vertical spaces

4. **Monochrome**
   - Black, white, or single color versions
   - Use for: Print, emails, restricted color spaces

### 5.3 Brand Name Treatment

```
Logo: [Geometric Symbol]
Name: DesignQuote AI
Subtitle: Design with Confidence. Quote in Minutes.

Font: Geist (Medium weight)
Color: Forest Green
Spacing: 12px gap between symbol and text
```

---

## 6. COMPONENT LIBRARY

### 6.1 Buttons

**Primary Button**
```
Background: Forest Green (#4A6C5D)
Text: White
Border: None
Padding: 12px 24px
Border Radius: 6px
Font: 16px, 600 weight, Geist
Shadow: Subtle (0 2px 8px rgba(0,0,0,0.1))
Hover: Darker green (#3D5A4F)
Active: Even darker with inset shadow
```

**Secondary Button**
```
Background: Warm Beige (#D4A574)
Text: Charcoal Gray (#2B3E3A)
Border: 2px solid Warm Beige
Padding: 12px 24px
Border Radius: 6px
Font: 16px, 600 weight, Geist
Hover: Slightly darker beige
```

**Outline Button**
```
Background: Transparent
Text: Forest Green
Border: 2px solid Forest Green
Padding: 12px 24px
Border Radius: 6px
Hover: Light green background
```

**Text Button**
```
Background: Transparent
Text: Forest Green
Border: None
Font-weight: 600
Underline: On hover
```

### 6.2 Cards

**Standard Card**
```
Background: Cream (#F8F6F1) or White
Border: 1px solid Light Gray (#D9D6D1)
Border Radius: 8px
Padding: 24px
Shadow: 0 2px 12px rgba(0,0,0,0.05)
Hover: Slightly darker shadow, subtle scale
```

**Premium Card** (Featured)
```
Background: White
Border: 2px solid Warm Beige
Border Radius: 8px
Padding: 32px
Shadow: 0 8px 24px rgba(0,0,0,0.1)
Ring/Highlight: Yes (ring-2 ring-beige)
```

### 6.3 Form Elements

**Input Field**
```
Background: White
Border: 1px solid Light Gray
Border Radius: 6px
Padding: 12px 16px
Focus: 2px solid Forest Green border
Font: 16px, 400 weight, Geist
Placeholder: Medium gray
```

**Label**
```
Font: 14px, 600 weight, Geist
Color: Charcoal Gray
Margin Bottom: 8px
```

**Form Section**
```
Spacing Between Fields: 20px
Spacing Between Sections: 32px
Max Width: 500px (for optimal readability)
```

### 6.4 Badges & Tags

**Status Badge - Active**
```
Background: Sage Green with opacity
Color: Darker green
Border Radius: 16px
Padding: 6px 12px
Font: 12px, 600 weight
```

**Status Badge - Pending**
```
Background: Warm Beige with opacity
Color: Warm Beige darker
Padding: 6px 12px
Font: 12px, 600 weight
```

**Category Tag**
```
Background: Light Gray
Color: Charcoal Gray
Border Radius: 4px
Padding: 4px 8px
Font: 12px, 500 weight
```

---

## 7. LAYOUT & SPACING

### 7.1 Spacing System (8px Base)

```
--space-0: 0px
--space-1: 4px
--space-2: 8px
--space-3: 12px
--space-4: 16px
--space-5: 20px
--space-6: 24px
--space-7: 32px
--space-8: 40px
--space-9: 48px
--space-10: 56px
--space-12: 64px
--space-16: 80px
```

### 7.2 Section Spacing

**Padding:**
- Mobile: 16px horizontal, 24px vertical
- Tablet: 32px horizontal, 40px vertical
- Desktop: 48px horizontal, 64px vertical

**Section Gaps:**
- Between sections: 64px (desktop), 40px (tablet), 32px (mobile)

**Container Max Width:** 1200px (desktop)

### 7.3 Grid System

**Desktop (1200px+):**
- 12-column grid
- Column width: ~96px
- Gutter: 24px

**Tablet (768px-1199px):**
- 8-column grid
- Column width: Variable
- Gutter: 16px

**Mobile (<768px):**
- 4-column grid
- Column width: Variable
- Gutter: 16px

### 7.4 Breakpoints

```css
--breakpoint-xs: 320px;    /* Extra small phones */
--breakpoint-sm: 480px;    /* Small phones */
--breakpoint-md: 768px;    /* Tablets */
--breakpoint-lg: 1024px;   /* Laptops */
--breakpoint-xl: 1280px;   /* Desktops */
--breakpoint-2xl: 1536px;  /* Large desktops */
```

---

## 8. PHOTOGRAPHY & IMAGERY GUIDELINES

### 8.1 Photography Style

**Key Characteristics:**
- Well-lit, clean compositions
- Natural, professional settings
- Warm lighting (soft golden hour tones)
- Focus on quality materials and textures
- People shown in authentic, professional moments
- Diverse representation
- Minimalist framing with strategic depth

### 8.2 Image Treatment

**Circular/Oval Images**
- Use for: Project showcases, before/after photos
- Aspect Ratio: 1:1 (square cropped to circle)
- Border: Subtle shadow, no visible border
- Overlay: Optional 10-15% dark overlay for text readability

**Hero Images**
- Large format for impact
- Aspect Ratio: 16:9 or 3:2
- Include circular accent elements
- Text overlay with dark gradient (40-60% opacity)

**Gallery Grids**
- Mixed sizes (primary 2-3x, secondary 1x)
- Aspect Ratios: Primarily 1:1, some 4:3
- Consistent spacing: 24px gaps
- Subtle hover effects (subtle scale, brightness increase)

### 8.3 Image Specifications

**Web Optimization:**
- Format: WebP with JPEG fallback
- Maximum width: 1920px
- Compression: Balanced quality/file size
- File sizes:
  - Hero images: 200-400KB
  - Card images: 80-150KB
  - Thumbnails: 30-50KB

### 8.4 Image Borders & Effects

**No Harsh Borders**
- Use subtle shadows instead
- Shadow: `0 4px 12px rgba(0,0,0,0.08)`

**Subtle Vignette** (Optional)
- Darkens edges slightly
- Draws eye to center
- Opacity: 5-10%

**Overlay Patterns** (Minimal)
- Geometric or dot patterns
- Opacity: 3-5%
- Only on hero or featured sections

---

## 9. ICON SYSTEM

### 9.1 Icon Style

**Design Principles:**
- Consistent stroke weight: 1.5-2px
- Rounded corners (3-4px)
- Balanced proportions
- Minimal detail, high clarity
- 24x24px base size

**Icon Categories:**

**Navigation Icons**
- Home, Search, Menu, Settings, User, Bell, etc.
- Simple, universally recognized
- Stroke style preferred

**Feature Icons**
- Larger, more detailed than navigation
- Can include subtle fill
- Used for feature highlights
- 48-64px size

**Status Icons**
- Checkmark, X, Warning, Info
- Color-coded for status
- Solid style (filled)
- 24-32px size

### 9.2 Icon Usage

**Color:**
- Primary: Forest Green (#4A6C5D)
- Secondary: Warm Beige (#D4A574)
- Neutral: Charcoal Gray (#2B3E3A)
- Success: Sage Green (#7A9A8C)
- Warning: Warm Orange (#E6A757)

**Sizing:**
- Navigation: 24px
- Button Icons: 20px
- Feature Icons: 48-64px
- Status Icons: 24-32px

**Spacing Around Icon:**
- Minimum 8px clear space
- In buttons: 8px margin between icon and text

### 9.3 Icon Library Recommendation

Use: **Feather Icons**, **Heroicons**, or **Tabler Icons**
- All match minimalist, professional aesthetic
- Consistent stroke weight
- Extensive icon coverage
- Easily customizable

---

## 10. TONE & VOICE

### 10.1 Brand Voice

**Professional Yet Approachable**
- Expert knowledge without jargon
- Confident but not arrogant
- Helpful and supportive

**Example:**
- ❌ "Utilize our advanced AI algorithms for quote optimization"
- ✅ "Get accurate quotes in seconds with AI"

### 10.2 Key Messaging

**Headlines:**
- Clear, benefit-focused
- Active voice preferred
- Emotional appeal balanced with logic
- 40-60 characters optimal

**Body Copy:**
- Scannable with short paragraphs
- Action-oriented verbs
- Specific benefits over features
- Conversational tone

**Calls-to-Action:**
- Action verb + benefit
- First person perspective
- Urgency without pressure

**Examples:**
- "Start Creating Quotes"
- "See It in Action"
- "Get 14 Days Free"
- "Join 500+ Designers"

### 10.3 Tone Guidelines

| Situation | Tone | Example |
|-----------|------|---------|
| Error Messages | Helpful & Clear | "Oops! Please add a project budget to continue." |
| Success Messages | Encouraging | "Perfect! Your quote is ready to share." |
| Feature Descriptions | Expert & Friendly | "Our AI learns your style to suggest accurate costs." |
| Testimonials | Authentic & Specific | "Saved us 5 hours per project." |
| CTAs | Confident & Action-oriented | "Let's Get Started" |

### 10.4 Words to Use

✓ Professional, Clean, Smart, Efficient, Elegant  
✓ Create, Generate, Simplify, Transform, Empower  
✓ Quick, Easy, Reliable, Accurate, Professional  

### 10.5 Words to Avoid

✗ Cheap, Basic, Simple (sounds unsophisticated)  
✗ Complex, Technical jargon, Confusing  
✗ Fake, Overhyped, "Revolutionary"  

---

## IMPLEMENTATION GUIDE

### For Web App (React/TypeScript)

```typescript
// colors.ts
export const colors = {
  primary: '#4A6C5D',
  accent: '#D4A574',
  background: '#F8F6F1',
  text: {
    dark: '#2B3E3A',
    body: '#5A5A5A',
    light: '#A0A0A0'
  },
  border: '#D9D6D1',
  state: {
    success: '#7A9A8C',
    warning: '#E6A757',
    error: '#C08080'
  }
};

// typography.ts
export const typography = {
  h1: {
    fontSize: '56px',
    fontWeight: 700,
    lineHeight: '1.2',
    letterSpacing: '-0.02em'
  },
  h2: {
    fontSize: '40px',
    fontWeight: 600,
    lineHeight: '1.3',
    letterSpacing: '-0.01em'
  },
  body: {
    fontSize: '16px',
    fontWeight: 400,
    lineHeight: '1.6',
    letterSpacing: '0'
  }
};

// spacing.ts
export const spacing = {
  0: '0px',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  7: '32px',
  8: '40px'
};
```

### For Tailwind CSS Configuration

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    colors: {
      primary: '#4A6C5D',
      accent: '#D4A574',
      background: '#F8F6F1',
      text: {
        dark: '#2B3E3A',
        body: '#5A5A5A'
      },
      border: '#D9D6D1'
    },
    fontFamily: {
      sans: ['Geist', 'system-ui', 'sans-serif'],
      serif: ['Lora', 'serif']
    },
    spacing: {
      0: '0px',
      1: '4px',
      2: '8px',
      3: '12px',
      4: '16px',
      5: '20px',
      6: '24px',
      7: '32px'
    }
  }
};
```

### For CSS Variables

```css
:root {
  /* Colors */
  --color-primary: #4A6C5D;
  --color-accent: #D4A574;
  --color-background: #F8F6F1;
  --color-text-dark: #2B3E3A;
  --color-text-body: #5A5A5A;
  --color-border: #D9D6D1;

  /* Typography */
  --font-family-base: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-family-serif: 'Lora', serif;
  --font-size-h1: 56px;
  --font-size-h2: 40px;
  --font-size-body: 16px;

  /* Spacing */
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
}
```

---

## COMPONENT EXAMPLES

### Button Component

```jsx
// Button.tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'outline';
  children: React.ReactNode;
  onClick?: () => void;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  children,
  onClick
}) => {
  const baseStyles = 'px-6 py-3 rounded-lg font-semibold transition-all';
  
  const variants = {
    primary: 'bg-primary text-white hover:bg-primary/90 shadow-md',
    secondary: 'bg-accent text-dark hover:bg-accent/90',
    outline: 'border-2 border-primary text-primary hover:bg-primary/5'
  };

  return (
    <button
      className={`${baseStyles} ${variants[variant]}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### Card Component

```jsx
// Card.tsx
interface CardProps {
  featured?: boolean;
  children: React.ReactNode;
}

export const Card: React.FC<CardProps> = ({ featured = false, children }) => {
  const baseStyles = featured
    ? 'bg-white border-2 border-accent rounded-lg p-8 shadow-lg'
    : 'bg-background border border-border rounded-lg p-6 shadow-sm hover:shadow-md';

  return <div className={baseStyles}>{children}</div>;
};
```

---

## DESIGN SYSTEM CHECKLIST

- [ ] Logo finalized and exported
- [ ] Color palette applied to all components
- [ ] Typography scale implemented
- [ ] Spacing system established
- [ ] Button styles created
- [ ] Card components designed
- [ ] Form elements styled
- [ ] Icon system integrated
- [ ] Responsive breakpoints tested
- [ ] Hover/Active states defined
- [ ] Accessibility (WCAG AA) verified
- [ ] Motion/Animation guidelines defined
- [ ] Documentation completed

---

## QUICK REFERENCE

**Primary Color:** #4A6C5D (Forest Green)  
**Accent Color:** #D4A574 (Warm Beige)  
**Background:** #F8F6F1 (Cream)  
**Text:** #2B3E3A (Charcoal Gray)  

**Primary Font:** Geist (sans-serif)  
**Accent Font:** Lora (serif)  

**Base Spacing:** 8px  
**Border Radius:** 6-8px  
**Shadow:** `0 2px 12px rgba(0,0,0,0.05)`  

**Brand Name:** DesignQuote AI  
**Tagline:** "Design with Confidence. Quote in Minutes."  

---

**Document Version:** 1.0  
**Created:** January 20, 2026  
**Status:** Ready for Implementation

---

### Next Steps
1. ✅ Review brand guide with team
2. ⏳ Create design system in Figma
3. ⏳ Export icon set
4. ⏳ Finalize logo variations
5. ⏳ Set up component library (Storybook)
6. ⏳ Implement in web app
7. ⏳ Test across all platforms
8. ⏳ Deploy landing page

