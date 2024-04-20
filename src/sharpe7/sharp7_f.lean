import Mathlib.Tactic

theorem shape7_1 (x₁ x₂: ℝ)
             (h₁ : f₁=1- x₁^2 - (x₂-1)^2)
             (h₂: I = (6*x₂)/5 + x₁^2/5 + x₂^2/2):
              0 < f₁
                →  I > 0 := by
  let p₀: ℝ := (11*x₂)/10
  let p₁: ℝ := (4*x₁)/5
  let σ₀: ℝ := 10/11*(p₀^2) + 5/4*(p₁^2)
  let σ₁: ℝ := 3/5
  have h1 : 10/11*(p₀^2) + 5/4*(p₁^2) = σ₀ := by exact rfl
  have h2 : 3/5 = σ₁ := by exact rfl
  have D₁: I = σ₀ + σ₁*f₁ := by
    linear_combination -(3/5)* h₁ + h₂ - h1 - f₁ * h2
  have l₀: σ₀ ≥ 0 := by
    rw [← h1]
    have : p₀ ^ 2 ≥ 0 := by
          exact sq_nonneg p₀
    have : p₁ ^ 2 ≥ 0 := by
          exact sq_nonneg p₁
    linarith
  have l₁: σ₁ > 0 := by
    rw [← h2]
    linarith
  rw [D₁]
  intro f
  have s₁ : 0 < σ₁*f₁ := by
    exact Right.mul_pos l₁ f
  linarith
