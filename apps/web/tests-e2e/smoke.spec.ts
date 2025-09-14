import { test, expect } from '@playwright/test';
test('home redirects to feed', async ({ page }) => {
await page.goto('/');
await expect(page).toHaveURL(//feed$/);
});
