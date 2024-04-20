import Mathlib.Tactic

theorem halfplane_2 (x₁ x₂: ℝ)
            (h₁ : g₁= x₂- x₁- 1)
            (h₂ : I =(9*x₁)/5 - (9*x₂)/5 - 3/5)
              :
              0 ≤ g₁
              → I ≤ 0 := by
  let δ₀: ℝ := 12/5
  let δ₁: ℝ := 9/5
  have h1 : 12/5= δ₀ := by exact rfl
  have h2 : 9/5= δ₁ := by  exact rfl
  have I₁: I = -δ₀ - δ₁*g₁ := by
    linear_combination 9/5 * h₁  + h₂ + h1 + g₁ * h2
  have l₀ : δ₀ ≥ 0 := by
    linarith
  have l₁: 0 ≤ δ₁ := by
    rw [← h2]
    linarith
  rw [I₁]
  intro g
  have s₁ : 0 ≤ δ₁*g₁ := by
    exact Right.mul_nonneg l₁ g
  linarith
