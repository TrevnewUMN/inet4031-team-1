import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
};

export default function () {
  http.get('http://localhost:8091/api/incidents');
  sleep(1);
}
