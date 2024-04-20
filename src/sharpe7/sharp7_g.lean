import Mathlib.Tactic

theorem shape7_2 (x₁ x₂: ℝ)
            (h₁ : g₁ = 1- x₁^2- (x₂+1)^2)
            (h₃ : I = (6*x₂)/5 + x₁^2/5 + x₂^2/2)
              :
              0 ≤ g₁
              → I ≤ 0 := by
  let p₁: ℝ := x₂/10
  let p₂: ℝ := (2*x₁)/5
  let δ₀: ℝ := 10*(p₁^2) + 5/2*(p₂^2)
  let δ₁: ℝ := 3/5
  have h1 : 10*(p₁^2) + 5/2*(p₂^2) = δ₀ := by exact rfl
  have h2 : 3/5= δ₁ := by  exact rfl
  have D₁: I = -δ₀ - δ₁*g₁ := by
    linear_combination 3/5 * h₁ + h₃ + h1 + g₁ * h2
  have l₀ : δ₀ ≥ 0 := by
    rw [← h1]
    have : p₁ ^ 2 ≥ 0 := by
      exact sq_nonneg p₁
    have : p₂ ^ 2  ≥ 0 := by
        exact sq_nonneg p₂
    linarith
  have l₁: 0 ≤ δ₁ := by
    rw [← h2]
    linarith
  rw [D₁]
  intro g
  have s₁ : 0 ≤ δ₁*g₁ := by
    exact Right.mul_nonneg l₁ g
  linarith
