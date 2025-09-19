// Shared interfaces mirroring Flutter models (simplified)
export interface FileResource {
  fileURL: string;
  fileSummary?: string;
}

export interface ImgExplanation {
  imgURL: string;
  explanation?: string;
}

export interface SessionDoc {
  sessionName: string;
  fileResources?: Record<string, FileResource>;
  summary?: string;
  imgExplanations?: Record<string, ImgExplanation>;
  cardIDs?: string[];
  status?: string; // processing | generatingImages | complete
}

export interface CardDoc {
  sessionID: string;
  tags: string[];
  imgURL?: string;
  text: string;
}

export interface UserDoc {
  userName: string;
  uid: string;
  defaultSpeechRate: number;
  sessions?: Record<string, SessionDoc>;
  cards?: Record<string, CardDoc>;
}
