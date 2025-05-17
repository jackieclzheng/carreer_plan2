const baseURL = import.meta.env.VITE_API_BASE_URL;

export const http = async (url: string, options: RequestInit = {}) => {
  const response = await fetch(`${baseURL}${url}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
};