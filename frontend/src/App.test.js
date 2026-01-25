import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Add Soldier heading', () => {
  render(<App />);
  const headingElement = screen.getByRole('heading', { name: /Add Soldier/i });
  expect(headingElement).toBeInTheDocument();
});
