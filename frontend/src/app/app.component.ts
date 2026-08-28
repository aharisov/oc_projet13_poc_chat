import { Component, OnDestroy } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ChatService } from './chat/chat.service';

interface ChatMessage {
  conversationId?: string;
  sender?: string;
  role?: string;
  content: string;
  timestamp?: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnDestroy {

  conversationId = 'conversation-001';
  sender = 'Client';
  role = 'CUSTOMER';
  messageContent = '';

  connected = false;

  messages: ChatMessage[] = [];

  constructor(private readonly chatService: ChatService) {
  }

  connect(): void {
    if (!this.conversationId.trim()) {
      return;
    }

    this.chatService.connect(
      this.conversationId,
      rawMessage => {
        const message = JSON.parse(rawMessage) as ChatMessage;
        this.messages.push(message);
      },
      connected => {
        this.connected = connected;
      }
    );
  }

  sendMessage(): void {
    if (!this.messageContent.trim()) {
      return;
    }

    this.chatService.send({
      sender: this.sender,
      role: this.role,
      content: this.messageContent
    });

    this.messageContent = '';
  }

  disconnect(): void {
    this.chatService.disconnect();
  }

  ngOnDestroy(): void {
    this.chatService.disconnect();
  }
}