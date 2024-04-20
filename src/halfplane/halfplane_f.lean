import Mathlib.Tactic

theorem halfplane_1 (x₁ x₂: ℝ)
             (h₁ : f₁=-x₂+x₁-1)
             (h₂: I = (9*x₁)/5 - (9*x₂)/5 - 3/5):
              0 < f₁
                →  I > 0 := by
  let ε: ℝ := 1/10000
  let σ₀: ℝ := 6/5-1/10000
  let σ₁: ℝ := 9/5
  have h1 :6/5-1/10000= σ₀ := by exact rfl
  have h2 : 9/5 = σ₁ := by exact rfl
  have D₁: I = σ₀ + σ₁*f₁  + ε := by
    linear_combination -(9/5)* h₁ + h₂ - h1 - f₁ * h2  - 1/10000
  have l₀: σ₀ ≥ 0 := by
    rw [← h1]
    linarith
  have l₁: σ₁ > 0 := by
    rw [← h2]
    linarith
  rw [D₁]
  intro f
  have h5 : ε >  0 := by norm_num
  have s₁ : 0 < σ₁*f₁ := by
    exact Right.mul_pos l₁ f
  linarith
