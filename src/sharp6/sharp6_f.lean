import Mathlib.Tactic


theorem sharp6_1 (x₁ x₂: ℝ)
             (h₁ : f₁=x₁^2+(x₂-2)^2-4)
             (h₂: I = (19*x₁^2)/1000 - (6*x₂)/125 + (11*x₂^2)/500):
              0 < f₁
                →  I > 0 := by
  let p₁: ℝ := x₂/100
  let p₂: ℝ := (7*x₁)/1000
  let σ₀: ℝ := 100*(p₁^2) + 1000/7*(p₂^2)
  let σ₁: ℝ := 3/250
  have h1 :100*(p₁^2) + 1000/7*(p₂^2) = σ₀ := by exact rfl
  have h2 : 3/250 = σ₁ := by  exact rfl
  have D₁: I = σ₀ + σ₁*f₁ := by
    linear_combination -(3/250)* h₁ + h₂ - h1 - f₁ * h2
  have l₀: σ₀ ≥ 0 := by
    rw [← h1]
    have : p₁ ^ 2 ≥ 0 := by
          exact sq_nonneg p₁
    have : p₂ ^ 2 ≥ 0 := by
          exact sq_nonneg p₂
    linarith
  have l₁: σ₁ > 0 := by
    rw [← h2]
    linarith
  rw [D₁]
  intro f
  have s₁ : 0 < σ₁*f₁ := by
    exact Right.mul_pos l₁ f
  linarith
