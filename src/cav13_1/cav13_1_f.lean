import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem cav13_1_f (x₁ x₂ : ℝ)
                  (h₁ : f₁ = x₁^2 - 2 * x₂^2 - 4)
                  (h₂ : I = x₁/5 - (3*x₂)/2 + (x₁*x₂)/10 + (9*x₁^2)/10 - (9*x₂^2)/10 - 1/2) :
                  0 ≤ f₁ → 0 ≤ I := by
  let p₀ : ℝ := x₁/10 - (3*x₂)/4 + 26999/10000
  let p₁ : ℝ := (41999*x₁)/539980 + (132743*x₂)/269990
  let p₂ : ℝ := (445973*x₁)/5309720
  let σ₀ : ℝ := 10000/26999*p₀^2 + 269990/132743*p₁^2 + 5309720/445973*p₂^2
  let σ₁ : ℝ := 4/5
  let ε : ℝ := 1/10000
  have I₁ : I = σ₀ + σ₁*f₁ + ε := by
    simp [h₁,h₂]
    linear_combination
  intro f1
  rw [I₁]
  have h1 : 0 ≤ σ₀ := by
    have : 0 ≤ (x₁/10 - (3*x₂)/4 + 26999/10000)^2 := by apply pow_two_nonneg
    have : 0 ≤ ((41999*x₁)/539980 + (132743*x₂)/269990)^2 := by apply pow_two_nonneg
    have : 0 ≤ ((445973 * x₁) ^ 2 / 5309720 ^ 2) := by
      rw [←div_pow]
      have : 0 ≤ (445973 * x₁ / 5309720) ^ 2 := by apply pow_two_nonneg
      linarith
    simp
    linarith
  have h2 : 0 ≤ σ₁*f₁ := by simp; linarith
  have h3 : 0 ≤ ε := by norm_num
  linarith
