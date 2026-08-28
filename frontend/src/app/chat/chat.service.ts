import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ChatService {

  private socket?: WebSocket;

  connect(
    conversationId: string,
    onMessage: (message: string) => void,
    onStatusChange?: (connected: boolean) => void
  ): void {
    const url =
      `ws://localhost:8080/ws?conversationId=${encodeURIComponent(conversationId)}`;

    this.socket = new WebSocket(url);

    this.socket.onopen = () => {
      onStatusChange?.(true);
    };

    this.socket.onmessage = event => {
      onMessage(event.data);
    };

    this.socket.onclose = () => {
      onStatusChange?.(false);
    };

    this.socket.onerror = () => {
      onStatusChange?.(false);
    };
  }

  send(message: object): void {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      return;
    }

    this.socket.send(JSON.stringify(message));
  }

  disconnect(): void {
    this.socket?.close();
    this.socket = undefined;
  }
}