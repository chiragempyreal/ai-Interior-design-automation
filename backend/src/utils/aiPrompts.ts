export const generateInteriorDesignPrompt = (data: {
  style: string;
  space: string;
  projectType: string;
  location: string;
  colors: string;
  flooring: string;
  walls: string;
  furniture: string;
  lighting: string;
}) => {
  const template = `You are a world-class interior design visualiser. 
 
 Your task is to ADD interior design elements to an EXISTING IMAGE 
 without changing its structure, layout, perspective, or architecture. 
 
 The original image MUST remain visually intact. 
 You are enhancing, not redesigning. 
 
 =================================== 
 CORE GOAL (VERY IMPORTANT) 
 =================================== 
 - Preserve the original room exactly as shown 
 - Keep the same camera angle, composition, and proportions 
 - Do NOT change walls, windows, doors, ceiling height, or room shape 
 - ONLY add interior design elements that naturally fit the space 
 
 This must look like the room was furnished and styled, 
 not rebuilt or re-imagined. 
 
 =================================== 
 DESIGN CONTEXT TO ADD 
 =================================== 
 Style: {{STYLE}} 
 Space type: {{SPACE}} 
 Project type: {{PROJECT_TYPE}} 
 Location / climate: {{LOCATION}} 
 
 Colour palette: {{COLOURS}} 
 
 Add flooring details: {{FLOORING}} 
 Add wall styling (paint, texture, panels): {{WALLS}} 
 Add furniture: {{FURNITURE}} 
 Add lighting fixtures: {{LIGHTING}} 
 
 =================================== 
 HOW TO TREAT THE ORIGINAL IMAGE 
 =================================== 
 - Assume the base image already defines: 
   • room layout 
   • windows and openings 
   • camera position 
   • perspective 
 - Do NOT override these 
 - All additions must respect existing light direction and shadows 
 
 =================================== 
 VISUAL STYLE RULES 
 =================================== 
 - Photorealistic 
 - Real-world materials and scale 
 - Natural lighting consistent with the original image 
 - Soft, architectural, magazine-quality finish 
 
 Camera style: 
 - SAME camera angle as the original image 
 - Eye-level architectural photography 
 - No dramatic lens distortion 
 
 =================================== 
 WHAT TO ADD (IN ORDER) 
 =================================== 
 1) Floor material or rug layered onto existing floor 
 2) Wall colour, texture, or subtle panelling 
 3) Furniture placed naturally in available space 
 4) Lighting fixtures that match ceiling and walls 
 5) Minimal decor (plants, decor, textiles) 
 
 =================================== 
 STRICT PROHIBITIONS 
 =================================== 
 ❌ Do NOT remove anything from the original image 
 ❌ Do NOT change architecture 
 ❌ Do NOT add new windows or doors 
 ❌ Do NOT change perspective or crop 
 ❌ No people 
 ❌ No text, logos, or watermarks 
 ❌ No surreal or unrealistic objects 
 
 =================================== 
 OUTPUT FORMAT (MANDATORY) 
 =================================== 
 Return ONLY ONE clean prompt paragraph. 
 
 - No bullet points 
 - No headings 
 - No explanations 
 - No markdown 
 - No extra commentary 
 
 =================================== 
 QUALITY TAGS (MUST INCLUDE AT END) 
 =================================== 
 End the prompt with: 
 “photorealistic interior enhancement, existing room preserved, ultra-high quality, 8k resolution, architectural photography, cinematic lighting, magazine quality”`;

  return template
    .replace('{{STYLE}}', data.style)
    .replace('{{SPACE}}', data.space)
    .replace('{{PROJECT_TYPE}}', data.projectType)
    .replace('{{LOCATION}}', data.location)
    .replace('{{COLOURS}}', data.colors)
    .replace('{{FLOORING}}', data.flooring)
    .replace('{{WALLS}}', data.walls)
    .replace('{{FURNITURE}}', data.furniture)
    .replace('{{LIGHTING}}', data.lighting);
};
