import PDFDocument from 'pdfkit';
import fs from 'fs';
import path from 'path';
import { IQuote } from '../models/Quote';
import { IProject } from '../models/Project';

export const generateQuotePDF = async (quote: IQuote, project: IProject): Promise<string> => {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 50 });
      const filename = `quote-${quote._id}-${Date.now()}.pdf`;
      const uploadDir = path.join(process.cwd(), 'uploads/quotes');
      
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }

      const filePath = path.join(uploadDir, filename);
      const writeStream = fs.createWriteStream(filePath);
      const publicUrl = `/uploads/quotes/${filename}`;

      doc.pipe(writeStream);

      // --- Header ---
      doc
        .fillColor('#444444')
        .fontSize(20)
        .text('InteriAI Design Quote', 110, 57)
        .fontSize(10)
        .text('123 Design Street', 200, 65, { align: 'right' })
        .text('Creative City, 10001', 200, 80, { align: 'right' })
        .moveDown();

      // --- Client Info ---
      doc
        .fillColor('#000000')
        .fontSize(12)
        .text(`Quote ID: ${quote._id}`, 50, 130)
        .text(`Date: ${new Date().toLocaleDateString()}`, 50, 145)
        .text(`Valid Until: ${new Date(quote.validUntil).toLocaleDateString()}`, 50, 160)
        
        .text(`Bill To:`, 300, 130)
        .font('Helvetica-Bold')
        .text(project.clientName, 300, 145)
        .font('Helvetica')
        .text(project.clientEmail, 300, 160)
        .moveDown();

      // --- Project Info ---
      doc
        .rect(50, 190, 500, 25)
        .fill('#f0f0f0')
        .stroke()
        .fill('#000000')
        .font('Helvetica-Bold')
        .fontSize(10)
        .text(`Project: ${project.title} (${project.projectType})`, 60, 197);

      // --- Table Header ---
      let y = 240;
      doc
        .font('Helvetica-Bold')
        .fontSize(10)
        .text('Item', 50, y)
        .text('Category', 200, y)
        .text('Quantity', 300, y, { width: 60, align: 'right' })
        .text('Unit Price', 370, y, { width: 70, align: 'right' })
        .text('Total', 450, y, { width: 70, align: 'right' });

      doc
        .moveTo(50, y + 15)
        .lineTo(550, y + 15)
        .stroke();

      y += 30;

      // --- Table Rows ---
      doc.font('Helvetica');
      let totalAmount = 0;

      quote.items.forEach((item) => {
        // Check for page break
        if (y > 700) {
          doc.addPage();
          y = 50;
        }

        doc
          .fontSize(10)
          .text(item.name, 50, y)
          .text(item.category, 200, y)
          .text(item.quantity.toString(), 300, y, { width: 60, align: 'right' })
          .text(`$${item.unitPrice.toFixed(2)}`, 370, y, { width: 70, align: 'right' })
          .text(`$${item.totalPrice.toFixed(2)}`, 450, y, { width: 70, align: 'right' });

        totalAmount += item.totalPrice;
        y += 20;
      });

      doc
        .moveTo(50, y + 10)
        .lineTo(550, y + 10)
        .stroke();

      // --- Total ---
      y += 20;
      doc
        .font('Helvetica-Bold')
        .fontSize(12)
        .text('Total Estimated Cost:', 300, y, { width: 140, align: 'right' })
        .text(`$${totalAmount.toFixed(2)}`, 450, y, { width: 70, align: 'right' });

      // --- Footer ---
      doc
        .fontSize(10)
        .font('Helvetica')
        .text(
          'This is an AI-generated estimate. Final costs may vary based on actual material selection and labor rates.',
          50,
          700,
          { align: 'center', width: 500 }
        );

      doc.end();

      writeStream.on('finish', () => {
        resolve(publicUrl);
      });

      writeStream.on('error', (err) => {
        reject(err);
      });

    } catch (error) {
      reject(error);
    }
  });
};
